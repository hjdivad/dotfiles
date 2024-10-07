use anyhow::{bail, Context, Result};
use shell::*;
use std::path::PathBuf;
use std::process::Command;
use thiserror::Error;
use tracing::{debug, info, trace, warn};

use super::VadnuConfig;

#[derive(Debug, Error)]
pub enum Error {
    /// (vadnu_dir, msg) error tuple
    #[error("vadnu-dir {0} is not readable: {1}")]
    UnreadableVadnuDir(String, String),

    /// (vadnu_dir, msg) error tuple
    #[error("rsync-dir {0} is not readable: {1}")]
    UnreadableRsyncDir(String, String),
}

macro_rules! git_commit {
    ($args:expr) => {
        sh!(&format!(r#"git commit --author="vadnu-sync[bot] <vadnu-sync@david.hamilton.gg>" --no-gpg-sign --allow-empty {}"#, $args))
    };
}

/// Sync local vadnu (or a subpath of it) with some rsync.
///
/// Creates three commits
///
///     - local snapshot
///     - remote snapshot
///     - local cherry-pick (trump remote changes)
///
/// The three commits are always created so might be empty.
///
/// The idea is that syncing should be scheduled to be done "soon after the end of the work period"
/// which means the most recent changes are local.  There should generally not be conflicts if
/// syncing is done regularly.
pub fn sync(config: &VadnuConfig) -> Result<()> {
    info!("sync {:?}", &config);

    preflight_check(config)?;

    let vadnu_sync_dir = config.vadnu_sync_path();
    let mut local_snapshot_sha = "".to_string();
    let mut remote_snapshot_sha = "".to_string();

    debug!("git commit: local snapshot");
    in_dir!(&config.vadnu_dir, {
        sh!(r#"git add ."#)?;
        git_commit!(r#"-m "local: snapshot""#)?;
        local_snapshot_sha = sh!(r#"git rev-parse --short HEAD"#)?;

        Ok(())
    })?;

    debug!("rsync from remote");
    sh!(&format!(
        r#"rsync --delete --recursive --links --safe-links --perms --executability --times --exclude ".git" "{}/" "{}""#,
        &config.rsync_dir.to_string_lossy(),
        vadnu_sync_dir.to_string_lossy(),
    ))?;

    in_dir!(&config.vadnu_dir, {
        debug!("git commit: remote snapshot");

        sh!(r#"git add ."#)?;
        git_commit!(r#"-m "remote: snapshot""#)?;
        remote_snapshot_sha = sh!(r#"git rev-parse --short HEAD"#)?;

        debug!("git cherry-pick local commit");
        // we now have local snapshot and remote snapshot
        // cherry-pick the local snapshot and make sure it wins all conflicts

        let mut command = Command::new("git");
        command.current_dir(&config.vadnu_dir);
        command.args(vec![
            "cherry-pick",
            "--no-commit",
            "--strategy",
            "ort",
            "-X",
            "theirs",
            "HEAD~1",
        ]);

        let output = command.output();
        let output = output.context(format!("cmd: {:?}", command))?;

        // if cherry-pick had a conflict from DD, UD, resolve those conflicts
        if !output.status.success() {
            let mut stderr = String::from_utf8(output.stderr)?;
            stderr = stderr.trim().to_string();

            if stderr.contains("CONFLICT") || stderr.contains("conflicts") {
                resolve_cherry_pick_conflicts(config)?;
            } else {
                let mut stdout = String::from_utf8(output.stdout)?;
                stdout = stdout.trim().to_string();
                bail!(
                    "cmd: {:?}\n\nout:\n\n{}\n\nerr:\n\n{}",
                    "git cherry-pick --no-commit --strategy ort -X theirs HEAD~1",
                    stdout,
                    stderr
                );
            }
        }

        git_commit!(r#"-m "local: overwrite conflicts with remote""#)?;

        Ok(())
    })?;

    in_dir!(&config.vadnu_dir, {
        let remotes = sh!(r#"git remote"#)?;
        // `git remote` doesn't print anything when there are no remotes
        if !remotes.is_empty() {
            sh!(r#"git push"#)?;
        }

        Ok(())
    })?;

    // rsync to remote
    sh!(&format!(
        r#"rsync --delete --recursive --links --safe-links --perms --executability --times --exclude ".git" "{}/" "{}""#,
        vadnu_sync_dir.to_string_lossy(),
        &config.rsync_dir.to_string_lossy()
    ))?;

    debug!("sync complete");

    Ok(())
}

pub fn preflight_check(config: &VadnuConfig) -> Result<()> {
    let vadnu_dir = &config.vadnu_dir;
    let rsync_dir = &config.rsync_dir;

    if !vadnu_dir.exists() {
        return Err(anyhow::Error::new(Error::UnreadableVadnuDir(
            vadnu_dir.to_string_lossy().to_string(),
            "path does not exist".to_string(),
        )));
    }

    if vadnu_dir.read_dir().is_err() {
        return Err(anyhow::Error::new(Error::UnreadableVadnuDir(
            vadnu_dir.to_string_lossy().to_string(),
            "dir exists but cannot be read".to_string(),
        )));
    }

    if !rsync_dir.exists() {
        return Err(anyhow::Error::new(Error::UnreadableRsyncDir(
            rsync_dir.to_string_lossy().to_string(),
            "path does not exist".to_string(),
        )));
    }

    if rsync_dir.read_dir().is_err() {
        return Err(anyhow::Error::new(Error::UnreadableRsyncDir(
            rsync_dir.to_string_lossy().to_string(),
            "dir exists but cannot be read".to_string(),
        )));
    }

    Ok(())
}

fn resolve_cherry_pick_conflicts(config: &VadnuConfig) -> Result<()> {
    //
    // A           U    unmerged, added by us
    // A           A    unmerged, both added
    // U           A    unmerged, added by them
    // D           U    unmerged, deleted by us
    // U           U    unmerged, both modified

    // DD, UD will still conflict even with -s ort -X theirs
    // But resolving is easy -- just delete the file harder
    debug!("resolve git conflicts");
    in_dir!(&config.vadnu_dir, {
        let git_status = sh!(r#"git status --short"#)?;
        trace!("git status:\n{}", git_status);

        // DU bravo/a.md
        // D  bravo/b.md
        // A  bravo/f.md
        for line in git_status.lines() {
            let status = &line[..2];
            let file_path = line[3..].trim();

            trace!("git status: '{}' path: '{}'", status, file_path);

            match status {
                "DU" => {
                    trace!("git add {}", file_path);
                    sh!(&format!("git add {}", file_path))?;
                }
                "UD" => {
                    trace!("git rm {}", file_path);
                    sh!(&format!("git rm {}", file_path))?;
                }
                "AU" | "UA" | "UU" => {
                    warn!("cherry-pick unhandled: '{}' '{}'", status, file_path);
                }
                _ => {
                    trace!("noop {}", file_path);
                }
            }
        }
        Ok(())
    })
}

#[cfg(test)]
mod tests {
    use core::panic;
    use insta::assert_debug_snapshot;
    use std::{collections::BTreeMap, fs};
    use tempfile::tempdir;
    use tracing_subscriber::EnvFilter;

    use super::*;

    struct TestConfig {
        vadnu_config: VadnuConfig,
        git_remote_path: Option<PathBuf>,
    }

    fn home_test_config() -> Result<TestConfig> {
        let remote_dir = tempfile::tempdir()?;
        let vadnu_dir = tempdir()?;
        let rsync_dir = tempdir()?;

        Ok(TestConfig {
            git_remote_path: Some(remote_dir.into_path()),
            vadnu_config: VadnuConfig {
                vadnu_dir: vadnu_dir.into_path(),
                rsync_dir: rsync_dir.into_path(),
                sync_path: Some("bravo".into()),
            },
        })
    }

    fn work_test_config() -> Result<TestConfig> {
        let vadnu_dir = tempdir()?;
        let rsync_dir = tempdir()?;

        Ok(TestConfig {
            git_remote_path: None,
            vadnu_config: VadnuConfig {
                vadnu_dir: vadnu_dir.into_path(),
                rsync_dir: rsync_dir.into_path(),
                sync_path: None,
            },
        })
    }

    fn init_log() -> Result<()> {
        let mut env_filter =
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("off"));

        env_filter = env_filter.add_directive("binutils::vadnu=trace".parse()?);
        tracing_subscriber::fmt().with_env_filter(env_filter).init();

        Ok(())
    }

    /// Sets up tests for syncing from home.
    ///
    /// This means that the local view is the entire repo and the remote view is scoped to the sync
    /// directory.
    ///
    /// The starting tree is:
    ///
    /// - alpha/
    ///     - a.md
    ///     - b.md
    /// - bravo/
    ///     - a.md
    ///     - b.md
    ///     - c.md
    ///     - d.md
    ///     - e.md
    ///
    /// And the local changes transform the tree to:
    ///
    /// - alpha/
    ///     - a.md      local UPDATED
    ///     - b.md
    ///     - c.md      local NEW
    /// - bravo/
    ///     - a.md      local UPDATED
    ///     - ~~b.md~~  local DELETED
    ///     - c.md
    ///     - d.md
    ///     - e.md
    ///     - f.md      local NEW
    /// - charlie/
    ///     - a.md    local NEW
    fn setup_home_test(config: &TestConfig) -> Result<()> {
        init_log()?;

        let vadnu_dir = &config.vadnu_config.vadnu_dir;
        let sync_dir = &config.vadnu_config.rsync_dir;
        let git_remote_path = config
            .git_remote_path
            .clone()
            .ok_or(anyhow::anyhow!("setup_home_test requires git_remote_path"))?;

        let initial_local_file_map = BTreeMap::from([
            ("alpha/a.md".to_string(), "alpha/a".to_string()),
            ("alpha/b.md".to_string(), "alpha/b".to_string()),
            ("bravo/a.md".to_string(), "bravo/a".to_string()),
            ("bravo/b.md".to_string(), "bravo/b".to_string()),
            ("bravo/c.md".to_string(), "bravo/c".to_string()),
            ("bravo/d.md".to_string(), "bravo/d".to_string()),
            ("bravo/e.md".to_string(), "bravo/e".to_string()),
        ]);
        let initial_remote_file_map = BTreeMap::from([
            ("a.md".to_string(), "bravo/a".to_string()),
            ("b.md".to_string(), "bravo/b".to_string()),
            ("c.md".to_string(), "bravo/c".to_string()),
            ("d.md".to_string(), "bravo/d".to_string()),
            ("e.md".to_string(), "bravo/e".to_string()),
        ]);

        in_dir!(&git_remote_path, {
            sh!("git init --bare")?;
            Ok(())
        })?;

        in_dir!(&vadnu_dir, {
            sh!("git init")?;
            sh!(&format!(
                "git remote add origin {}",
                &git_remote_path.to_string_lossy()
            ))?;
            git_commit!("-m 'root'")?;
            sh!("git push -u origin +master")?;

            fixturify::write(vadnu_dir, &initial_local_file_map)?;
            sh!("git add .")?;
            git_commit!("-m 'starting point'")?;

            let modifications_file_map = BTreeMap::from([
                (
                    "alpha/a.md".to_string(),
                    "alpha/a local UPDATED".to_string(),
                ),
                ("alpha/c.md".to_string(), "alpha/c local NEW".to_string()),
                (
                    "bravo/a.md".to_string(),
                    "bravo/a local UPDATED".to_string(),
                ),
                ("bravo/f.md".to_string(), "bravo/f local NEW".to_string()),
                (
                    "charlie/a.md".to_string(),
                    "charlie/a local NEW".to_string(),
                ),
            ]);
            fixturify::write(vadnu_dir, &modifications_file_map)?;
            fs::remove_file(vadnu_dir.join("bravo/b.md"))?;

            Ok(())
        })?;

        fixturify::write(sync_dir, &initial_remote_file_map)?;

        Ok(())
    }

    /// Sets up tests for syncing from work.
    ///
    /// This means that the local view is scoped to the sync dir.  The remote view is also just the
    /// sync dir.
    ///
    /// The starting tree is:
    ///
    /// - a.md
    /// - b.md
    /// - c.md
    /// - d.md
    /// - e.md
    ///
    /// And the local changes transform the tree to:
    ///
    /// - a.md      local UPDATED
    /// - ~~b.md~~  local DELETED
    /// - c.md
    /// - d.md
    /// - e.md
    /// - f.md      local NEW
    fn setup_work_test(config: &TestConfig) -> Result<()> {
        init_log()?;

        let vadnu_dir = &config.vadnu_config.vadnu_dir;
        let sync_dir = &config.vadnu_config.rsync_dir;
        assert!(config.git_remote_path.is_none());

        let initial_local_file_map = BTreeMap::from([
            ("a.md".to_string(), "bravo/a".to_string()),
            ("b.md".to_string(), "bravo/b".to_string()),
            ("c.md".to_string(), "bravo/c".to_string()),
            ("d.md".to_string(), "bravo/d".to_string()),
            ("e.md".to_string(), "bravo/e".to_string()),
        ]);
        let initial_remote_file_map = BTreeMap::from([
            ("a.md".to_string(), "bravo/a".to_string()),
            ("b.md".to_string(), "bravo/b".to_string()),
            ("c.md".to_string(), "bravo/c".to_string()),
            ("d.md".to_string(), "bravo/d".to_string()),
            ("e.md".to_string(), "bravo/e".to_string()),
        ]);

        in_dir!(&vadnu_dir, {
            sh!("git init")?;
            git_commit!("--allow-empty -m 'root'")?;

            fixturify::write(vadnu_dir, &initial_local_file_map)?;
            sh!("git add .")?;
            git_commit!("-m 'starting point'")?;

            let modifications_file_map = BTreeMap::from([
                ("a.md".to_string(), "bravo/a local UPDATED".to_string()),
                ("f.md".to_string(), "bravo/f local NEW".to_string()),
            ]);
            fixturify::write(vadnu_dir, &modifications_file_map)?;
            fs::remove_file(vadnu_dir.join("b.md"))?;

            Ok(())
        })?;

        fixturify::write(sync_dir, &initial_remote_file_map)?;

        Ok(())
    }

    #[test]
    fn test_home_sync_no_remote_changes() -> Result<()> {
        let config = home_test_config()?;
        setup_home_test(&config)?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "alpha/a.md": "alpha/a local UPDATED",
                "alpha/b.md": "alpha/b",
                "alpha/c.md": "alpha/c local NEW",
                "bravo/a.md": "bravo/a local UPDATED",
                "bravo/c.md": "bravo/c",
                "bravo/d.md": "bravo/d",
                "bravo/e.md": "bravo/e",
                "bravo/f.md": "bravo/f local NEW",
                "charlie/a.md": "charlie/a local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "c.md": "bravo/c",
                "d.md": "bravo/d",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_home_sync_remote_changes_no_conflicts() -> Result<()> {
        let config = home_test_config()?;
        setup_home_test(&config)?;

        let modifications_file_map = BTreeMap::from([
            (
                "alpha/a.md".to_string(),
                "bravo/alpha/a remote NEW".to_string(),
            ),
            ("c.md".to_string(), "bravo/c remote UPDATED".to_string()),
            ("g.md".to_string(), "bravo/g remote NEW".to_string()),
        ]);
        fixturify::write(&config.vadnu_config.rsync_dir, &modifications_file_map)?;
        fs::remove_file(config.vadnu_config.rsync_dir.join("d.md"))?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "alpha/a.md": "alpha/a local UPDATED",
                "alpha/b.md": "alpha/b",
                "alpha/c.md": "alpha/c local NEW",
                "bravo/a.md": "bravo/a local UPDATED",
                "bravo/alpha/a.md": "bravo/alpha/a remote NEW",
                "bravo/c.md": "bravo/c remote UPDATED",
                "bravo/e.md": "bravo/e",
                "bravo/f.md": "bravo/f local NEW",
                "bravo/g.md": "bravo/g remote NEW",
                "charlie/a.md": "charlie/a local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "alpha/a.md": "bravo/alpha/a remote NEW",
                "c.md": "bravo/c remote UPDATED",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
                "g.md": "bravo/g remote NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_home_sync_remote_changes_with_conflicts() -> Result<()> {
        let config = home_test_config()?;
        setup_home_test(&config)?;

        let modifications_file_map = BTreeMap::from([
            // modified by local
            ("a.md".to_string(), "bravo/a remote UPDATED".to_string()),
            // added by local
            ("f.md".to_string(), "bravo/f remote NEW".to_string()),
            // deleted by local
            ("b.md".to_string(), "bravo/b remote UPDATED".to_string()),
            // doesn't conflict
            ("e.md".to_string(), "bravo/e remote UPDATED".to_string()),
        ]);
        fixturify::write(&config.vadnu_config.rsync_dir, &modifications_file_map)?;
        // rm c does not conflict
        fs::remove_file(config.vadnu_config.rsync_dir.join("c.md"))?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "alpha/a.md": "alpha/a local UPDATED",
                "alpha/b.md": "alpha/b",
                "alpha/c.md": "alpha/c local NEW",
                "bravo/a.md": "bravo/a local UPDATED",
                "bravo/d.md": "bravo/d",
                "bravo/e.md": "bravo/e remote UPDATED",
                "bravo/f.md": "bravo/f local NEW",
                "charlie/a.md": "charlie/a local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "d.md": "bravo/d",
                "e.md": "bravo/e remote UPDATED",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_home_sync_remote_changes_with_conflict_deleted_by_us() -> Result<()> {
        let config = home_test_config()?;
        setup_home_test(&config)?;

        // local updated a.md, remote deleted a.md
        fs::remove_file(config.vadnu_config.rsync_dir.join("a.md"))?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "alpha/a.md": "alpha/a local UPDATED",
                "alpha/b.md": "alpha/b",
                "alpha/c.md": "alpha/c local NEW",
                "bravo/a.md": "bravo/a local UPDATED",
                "bravo/c.md": "bravo/c",
                "bravo/d.md": "bravo/d",
                "bravo/e.md": "bravo/e",
                "bravo/f.md": "bravo/f local NEW",
                "charlie/a.md": "charlie/a local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "c.md": "bravo/c",
                "d.md": "bravo/d",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_work_sync_no_remote_changes() -> Result<()> {
        let config = work_test_config()?;
        setup_work_test(&config)?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "c.md": "bravo/c",
                "d.md": "bravo/d",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "c.md": "bravo/c",
                "d.md": "bravo/d",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_work_sync_remote_changes_no_conflicts() -> Result<()> {
        let config = work_test_config()?;
        setup_work_test(&config)?;

        let modifications_file_map = BTreeMap::from([
            (
                "alpha/a.md".to_string(),
                "bravo/alpha/a remote NEW".to_string(),
            ),
            ("c.md".to_string(), "bravo/c remote UPDATED".to_string()),
            ("g.md".to_string(), "bravo/g remote NEW".to_string()),
        ]);
        fixturify::write(&config.vadnu_config.rsync_dir, &modifications_file_map)?;
        fs::remove_file(config.vadnu_config.rsync_dir.join("d.md"))?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "alpha/a.md": "bravo/alpha/a remote NEW",
                "c.md": "bravo/c remote UPDATED",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
                "g.md": "bravo/g remote NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "alpha/a.md": "bravo/alpha/a remote NEW",
                "c.md": "bravo/c remote UPDATED",
                "e.md": "bravo/e",
                "f.md": "bravo/f local NEW",
                "g.md": "bravo/g remote NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_work_sync_remote_changes_with_conflicts() -> Result<()> {
        let config = work_test_config()?;
        setup_work_test(&config)?;

        let modifications_file_map = BTreeMap::from([
            // modified by local
            ("a.md".to_string(), "bravo/a remote UPDATED".to_string()),
            // added by local
            ("f.md".to_string(), "bravo/f remote NEW".to_string()),
            // deleted by local
            ("b.md".to_string(), "bravo/b remote UPDATED".to_string()),
            // doesn't conflict
            ("e.md".to_string(), "bravo/e remote UPDATED".to_string()),
        ]);
        fixturify::write(&config.vadnu_config.rsync_dir, &modifications_file_map)?;
        // rm c does not conflict
        fs::remove_file(config.vadnu_config.rsync_dir.join("c.md"))?;

        sync(&config.vadnu_config)?;

        in_dir!(&config.vadnu_config.vadnu_dir, {
            assert_eq!(sh!("git status -s")?.trim(), "", "git is clean");
            Ok(())
        })?;

        let files = fixturify::read(&config.vadnu_config.vadnu_dir);

        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "d.md": "bravo/d",
                "e.md": "bravo/e remote UPDATED",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        let files = fixturify::read(&config.vadnu_config.rsync_dir);
        assert_debug_snapshot!(files, @r###"
        Ok(
            {
                "a.md": "bravo/a local UPDATED",
                "d.md": "bravo/d",
                "e.md": "bravo/e remote UPDATED",
                "f.md": "bravo/f local NEW",
            },
        )
        "###);

        Ok(())
    }

    #[test]
    fn test_preflight_vadnu_dir_missing() -> Result<()> {
        let config = home_test_config()?;

        fs::remove_dir(&config.vadnu_config.vadnu_dir)?;
        let result = sync(&config.vadnu_config);

        let Err(err) = result else {
            panic!("Expected sync() to error");
        };

        let Some(err) = err.downcast_ref::<crate::vadnu::sync::Error>() else {
            panic!("Unexpected error: {:?}", err);
        };

        let Error::UnreadableVadnuDir(_, _) = err else {
            panic!("Unexpected error: {:?}", err);
        };

        Ok(())
    }

    #[test]
    fn test_preflight_missing_rsync_dir() -> Result<()> {
        let config = home_test_config()?;

        fs::remove_dir(&config.vadnu_config.rsync_dir)?;
        let result = sync(&config.vadnu_config);

        let Err(err) = result else {
            panic!("Expected sync() to error");
        };

        let Some(err) = err.downcast_ref::<crate::vadnu::sync::Error>() else {
            panic!("Unexpected error: {:?}", err);
        };

        let Error::UnreadableRsyncDir(_, _) = err else {
            panic!("Unexpected error: {:?}", err);
        };

        Ok(())
    }
}
