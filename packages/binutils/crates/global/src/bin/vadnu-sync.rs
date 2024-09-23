use anyhow::{bail, Context, Result};
use clap::{Parser, Subcommand};
use serde::Serialize;
use shell::*;
use std::fs::{self, File, OpenOptions};
use std::path::Path;
use std::process::Command;
use std::{env, path::PathBuf};
use tracing::field::debug;
use tracing::{debug, info, trace};
use tracing_subscriber::fmt::time;
use tracing_subscriber::fmt::writer::{BoxMakeWriter, MakeWriterExt};
use tracing_subscriber::EnvFilter;
use xdg::BaseDirectories;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct CommandArgs {
    /// The vadnu directory.  Defaults to `$HOME/docs/vadnu`.
    #[arg(long)]
    vadnu_dir: Option<String>,

    /// The sync path within `vadnu`.
    #[arg(long)]
    sync_path: Option<String>,

    /// The rsync directory.  Defaults to `/Volumes/hjdivad.j/docs/vadnu/linkedin`.
    #[arg(long)]
    rsync_dir: Option<String>,

    /// Print logging
    #[arg(long, short = 'v', action = clap::ArgAction::Count)]
    verbose: u8,

    #[command(subcommand)]
    subcommand: VadnuCommand,
}

#[derive(Subcommand, Debug)]
enum VadnuCommand {
    /// Sync vadnu
    Sync,
    /// Inspect or modify daemon for auto-syncinc
    Daemon(DaemonArgs),
}

#[derive(Parser, Debug)]
struct DaemonArgs {
    #[command(subcommand)]
    subcommand: DaemonCommand,
}

#[derive(Subcommand, Debug)]
enum DaemonCommand {
    /// Check whether the daemon is installed
    Show,
    /// Install the daemon
    Install,
    /// Uninstall the daemon
    Uninstall,
}

#[derive(Debug)]
struct VadnuConfig {
    vadnu_dir: PathBuf,
    rsync_dir: PathBuf,
    sync_path: Option<String>,
}
// TODO: run daily; see ⬇️
// TODO: generate plist; see <https://chatgpt.com/c/37dbb44c-639d-458c-a94d-06a0fb481db4>
fn main() -> Result<()> {
    let args = CommandArgs::parse();

    init_logging(&args)?;

    let home = env_home()?;

    latest_bin::ensure_latest_bin()?;

    trace!("main()");

    let vadnu_dir = args
        .vadnu_dir
        .clone()
        .unwrap_or(format!("{}/docs/vadnu", home));
    let rsync_dir = args
        .rsync_dir
        .clone()
        .unwrap_or("/Volumes/hjdivad.j/docs/vadnu/linkedin".to_string());
    let sync_path = args.sync_path.clone();

    let config = VadnuConfig {
        vadnu_dir: vadnu_dir.into(),
        rsync_dir: rsync_dir.into(),
        sync_path,
    };

    match &args.subcommand {
        VadnuCommand::Sync => sync(&config),
        VadnuCommand::Daemon(daemon_args) => daemon(daemon_args, &args),
    }
}

fn xdg_log_path() -> Result<PathBuf> {
    let xdg_dirs = BaseDirectories::with_prefix("binutils")?;
    xdg_dirs
        .place_state_file("vadnu-sync.log")
        .context("tried to compute XDG_STATE log path")
}

fn xdg_error_path() -> Result<PathBuf> {
    let xdg_dirs = BaseDirectories::with_prefix("binutils")?;
    xdg_dirs
        .place_state_file("vadnu-sync.err")
        .context("tried to compute XDG_STATE error log path")
}

fn init_logging(options: &CommandArgs) -> Result<()> {
    let mut env_filter =
        EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("off"));

    let log_level = match options.verbose {
        1 => Some("info"),
        2 => Some("debug"),
        3 => Some("trace"),
        _ => None,
    };

    if let Some(log_level) = log_level {
        env_filter = env_filter.add_directive(format!("vadnu_sync={}", log_level).parse()?);
    }

    let log_file_path = xdg_log_path()?;

    let path = Path::new(&log_file_path);
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let file = OpenOptions::new()
        .append(true)
        .create(true)
        .open(log_file_path)?;
    let log_writer = BoxMakeWriter::new(file);
    let log_writer = log_writer.and(std::io::stdout);

    tracing_subscriber::fmt()
        .with_env_filter(env_filter)
        .with_writer(log_writer)
        .with_timer(time::ChronoLocal::rfc_3339())
        .init();

    Ok(())
}

impl VadnuConfig {
    fn vadnu_sync_path(&self) -> PathBuf {
        let vadnu_sync_dir = self.vadnu_dir.clone();
        if let Some(sync_path) = &self.sync_path {
            vadnu_sync_dir.join(sync_path)
        } else {
            vadnu_sync_dir
        }
    }
}

fn env_home() -> Result<String> {
    env::var("HOME").context("No $HOME - no idea what to do")
}

fn daemon(args: &DaemonArgs, global_args: &CommandArgs) -> Result<()> {
    let plist_file_path: PathBuf = format!(
        "{}/Library/LaunchAgents/gg.hamilton.vadnu_sync.plist",
        env_home()?
    )
    .into();

    match args.subcommand {
        DaemonCommand::Show => show_daemon(),
        DaemonCommand::Install => install_daemon(&plist_file_path, global_args),
        DaemonCommand::Uninstall => uninstall_daemon(&plist_file_path),
    }
}

/// Represents the `StartCalendarInterval` section in the plist.
#[derive(Serialize)]
#[serde(rename_all = "PascalCase")]
struct StartCalendarInterval {
    hour: u32,
    minute: u32,
}

/// Represents the entire plist structure.
#[derive(Serialize)]
#[serde(rename_all = "PascalCase")]
struct LaunchdPlist {
    label: String,
    program_arguments: Vec<String>,
    start_calendar_interval: StartCalendarInterval,
    #[serde(skip_serializing_if = "Option::is_none")]
    standard_out_path: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    standard_error_path: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    run_at_load: Option<bool>,
}

fn show_daemon() -> Result<()> {
    let in_launchctl = sh_q!(r#"launchctl list | rg gg.hamilton.vadnu_sync"#)?;
    if in_launchctl {
        println!("gg.hamilton.vadnu_sync loaded in launchctl");
    } else {
        println!("gg.hamilton.vadnu_sync not found in launchctl");
    }

    Ok(())
}

fn install_daemon(plist_file_path: &Path, args: &CommandArgs) -> Result<()> {
    write_plist(plist_file_path, args)?;

    debug!(
        "bootstrapping {} in launchctl",
        &plist_file_path.to_string_lossy()
    );
    // FIXME: This doesn't work
    // see <man launchd.plist>
    //
    // plutil -lint ~/Library/LaunchAgents/gg.hamilton.vadnu_sync.plist
    // seems okay; not clear on what the issue is, only error is "input/output error"
    //
    // 1. check man page
    // 2. try without the calendar interval & incrementally add it back
    sh!(&format!(
        "launchctl bootstrap user/$(id -u) {}",
        &plist_file_path.to_string_lossy()
    ))?;

    println!("daemon installed");

    Ok(())
}

fn uninstall_daemon(plist_file_path: &Path) -> Result<()> {
    Ok(())
}

fn write_plist(plist_file_path: &Path, args: &CommandArgs) -> Result<()> {
    debug!("Writing plist: {}", &plist_file_path.to_string_lossy());

    let label = "gg.hamilton.vadnu_sync";
    let binary_path = std::env::current_exe()?;
    // TODO: set args from `args`
    let args = vec!["-vv"];
    let hour = 2;
    let minute = 0;
    let stdout_path = xdg_log_path()?;
    let stderr_path = xdg_error_path()?;
    let run_at_load = Some(false);

    let mut program_args = Vec::new();
    program_args.push(binary_path.to_string_lossy().to_string());
    for arg in args {
        program_args.push(arg.to_string());
    }

    let launch_config = LaunchdPlist {
        label: label.to_string(),
        program_arguments: program_args,
        start_calendar_interval: StartCalendarInterval { hour, minute },
        standard_out_path: stdout_path.to_string_lossy().to_string().into(),
        standard_error_path: stderr_path.to_string_lossy().to_string().into(),
        run_at_load,
    };

    let file = OpenOptions::new()
        .create(true)
        .truncate(true)
        .write(true)
        .open(plist_file_path)?;
    plist::to_writer_xml(file, &launch_config).context("Writing plist XML")?;

    Ok(())
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
fn sync(config: &VadnuConfig) -> Result<()> {
    info!("sync {:?}", &config);

    // TODO: pre-flight check: do both dirs exist? (e.g. remote may not be mounted)

    let vadnu_sync_dir = config.vadnu_sync_path();
    let mut local_snapshot_sha = "".to_string();
    let mut remote_snapshot_sha = "".to_string();

    debug!("git commit: local snapshot");
    in_dir!(&config.vadnu_dir, {
        sh!(r#"git add ."#)?;
        sh!(r#"git commit --no-gpg-sign --allow-empty -m "local: snapshot""#)?;
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
        sh!(r#"git commit --no-gpg-sign --allow-empty -m "remote: snapshot""#)?;
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

        sh!(
            r#"git commit --no-gpg-sign --allow-empty -m "local: overwrite conflicts with remote""#
        )?;

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
        let file_paths = sh!(r#"git status --short | rg '^\wD (.*)$' -r '$1'"#)?;
        let file_paths = file_paths.trim().split("\n");
        for file_path in file_paths {
            trace!("git rm {}", file_path);
            sh!(&format!("git rm {}", file_path))?;
        }
        Ok(())
    })
}

// #!/usr/bin/env bash
// # vim:ft=bash
//
// __DIRNAME=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
//
// LOCAL_PATH="${__DIRNAME}/../linkedin"
// REMOTE_ROOT='/Volumes/hjdivad.j'
// REMOTE_PATH="${REMOTE_ROOT}/docs/vadnu/linkedin"
//
// if [[ ! -d "${REMOTE_PATH}" ]]; then
//   echo "No such directory '${REMOTE_PATH}'; is the nas mounted?"
//   exit 65 # no input
// fi
//
// # -n -v -v to get actual details
// rsync --delete --recursive --links --safe-links --perms --executability --times "${REMOTE_PATH}/" "${LOCAL_PATH}/"
// cp "${REMOTE_ROOT}/.pws" ${LOCAL_PATH}

#[cfg(test)]
mod tests {
    use insta::assert_debug_snapshot;
    use std::{collections::BTreeMap, fs};
    use tempfile::tempdir;

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

        env_filter = env_filter.add_directive(format!("vadnu_sync={}", "trace").parse()?);
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
            sh!("git commit --no-gpg-sign --allow-empty -m 'root'")?;
            sh!("git push -u origin +master")?;

            fixturify::write(vadnu_dir, &initial_local_file_map)?;
            sh!("git add .")?;
            sh!("git commit --no-gpg-sign -m 'starting point'")?;

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
            sh!("git commit --no-gpg-sign --allow-empty -m 'root'")?;

            fixturify::write(vadnu_dir, &initial_local_file_map)?;
            sh!("git add .")?;
            sh!("git commit --no-gpg-sign -m 'starting point'")?;

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
}
