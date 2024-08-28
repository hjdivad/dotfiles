use anyhow::Result;
use clap::Parser;
use shell::*;
use std::path::PathBuf;
use tracing_subscriber::EnvFilter;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct CommandArgs {
    #[arg(long)]
    dry_run: bool,

    /// Print debugging information
    #[arg(long)]
    debug: bool,
}

struct VadnuConfig {
    vadnu_dir: PathBuf,
    rsync_dir: PathBuf,
}
fn main() -> Result<()> {
    // Initialize tracing, but only if RUST_LOG is set
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("off")),
        )
        .init();

    latest_bin::ensure_latest_bin()?;

    let options = CommandArgs::parse();

    // TODO: read from config?
    let config = VadnuConfig {
        // TODO: crib ~/ support from start-tmux;  then it's ~/docs/vadnu
        vadnu_dir: "/Users/hjdivad/docs/vadnu".into(),
        rsync_dir: "/Volumes/hjdivad.j/docs/vadnu".into(),
    };
    sync(&config)
}

fn sync(config: &VadnuConfig) -> Result<()> {
    in_dir!(&config.vadnu_dir, {
        sh!(r#"git add ."#)?;
        sh!(r#"git commit --no-gpg-sign --allow-empty -m "Snapshot local""#)?;
        Ok(())

        // TODO: rsync from /Volumes/hjdivad.j/docs/vadnu
        // TODO: git snapshot remote B (allow empty)
        // TODO: rebase A onto B, A wins all conflicts
        // TODO: rsync to /Volumes/hjdivad.j/docs/vadnu
        // TODO: git push
    })
}


#[cfg(test)]
mod tests {
    use insta::assert_debug_snapshot;
    use std::{collections::BTreeMap, fs};
    use tempfile::{tempdir, TempDir};

    use super::*;

    fn test_config() -> Result<VadnuConfig> {
        let vadnu_dir = tempdir()?;
        let rsync_dir = tempdir()?;

        Ok(VadnuConfig {
            vadnu_dir: vadnu_dir.into_path(),
            rsync_dir: rsync_dir.into_path(),
        })
    }

    fn setup_test(config: &VadnuConfig) -> Result<()> {
        let vadnu_dir = &config.vadnu_dir;
        let sync_dir = &config.rsync_dir;
        let initial_file_map = BTreeMap::from([
            ("foo/a.md".to_string(), "foo/a".to_string()),
            ("foo/b.md".to_string(), "foo/b".to_string()),
            ("bar/c.md".to_string(), "bar/c".to_string()),
            ("bar/d.md".to_string(), "bar/d".to_string()),
        ]);

        in_dir!(&vadnu_dir, {
            sh!("git init")?;

            fixturify::write(vadnu_dir, &initial_file_map)?;
            sh!("git add .")?;
            sh!("git commit --no-gpg-sign -m 'starting point'")?;
            sh!("ls")?;

            let modifications_file_map = BTreeMap::from([
                ("bar/c.md".to_string(), "bar/c UPDATED".to_string()),
                ("bar/e.md".to_string(), "bar/e".to_string()),
            ]);
            fixturify::write(vadnu_dir, &modifications_file_map)?;
            fs::remove_file(vadnu_dir.join("bar/d.md"))?;

            Ok(())
        })?;

        fixturify::write(sync_dir, &initial_file_map)?;

        Ok(())
    }

    #[test]
    fn test_sync_no_remote_changes() -> Result<()> {
        let config = test_config()?;
        setup_test(&config)?;

        // Remote didn't do anything
        sync(&config);

        in_dir!(&config.vadnu_dir, {
            assert!(sh!("git status -s")?.trim().is_empty(), "git is clean");
            Ok(())
        })?;

        // TODO: read via ignore crate so we don't try to read .git/
        let files = fixturify::read(&config.vadnu_dir);

        assert_debug_snapshot!(files, @r"");

        Ok(())
    }

    fn test_sync_remote_changes_no_conflicts() -> Result<()> {
        Ok(())
    }

    fn test_sync_remote_changes_with_conflicts() -> Result<()> {
        Ok(())
    }
}
