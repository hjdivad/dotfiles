use std::{cell::RefCell, path::PathBuf};

use anyhow::{anyhow, Context, Result};
use clap::Parser;
use std::process::Command;
use tracing::{debug, info, trace};
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

fn sync(config: &VadnuConfig) {}

fn main() -> Result<()> {
    // Initialize tracing, but only if RUST_LOG is set
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("off")),
        )
        .init();

    latest_bin::ensure_latest_bin()?;

    let options = CommandArgs::parse();

    // TODO: git snapshot local A (allow empty)
    // TODO: rsync from /Volumes/hjdivad.j/docs/vadnu
    // TODO: git snapshot remote B (allow empty)
    // TODO: rebase A onto B, A wins all conflicts
    // TODO: rsync to /Volumes/hjdivad.j/docs/vadnu
    // TODO: git push

    Ok(())
}

use shell::*;

#[cfg(test)]
mod tests {
    use std::{collections::BTreeMap, path::Path};

    use tempfile::tempdir;

    use super::*;

    #[test]
    fn it_works() -> Result<()> {
        let vadnu_dir = tempdir()?;

        shell::in_dir!(&vadnu_dir.path(), {
            sh!("git init")?;

            let path = &vadnu_dir.path().to_string_lossy();
            let file_map = BTreeMap::from([
                ("foo/a.md".to_string(), "foo/a".to_string()),
                ("foo/b.md".to_string(), "foo/b".to_string()),
                ("bar/c.md".to_string(), "bar/c".to_string()),
                ("bar/d.md".to_string(), "bar/d".to_string()),
            ]);
            println!("{}", path);
            fixturify::write(vadnu_dir.path(), file_map)?;
            sh!("git add .")?;
            sh!("git commit -m 'starting point'")?;
            sh!("ls")?;

            // TODO: make changes (add, modify, remove)
            // TODO: snapshot
            // sync remote
            //  - no remote changes
            //  - remote non-conflicting changes (add modify remove)
            //  - remote conflicting changes (add modify remove)

            Ok(())
        })
    }
}
