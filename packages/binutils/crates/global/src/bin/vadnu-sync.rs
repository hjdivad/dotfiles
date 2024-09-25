use anyhow::{bail, Context, Result};
use binutils::vadnu::daemon::{install_daemon, show_daemon, uninstall_daemon};
use binutils::vadnu::sync::sync;
use binutils::vadnu::util::{env_home, init_logging, LoggingOptions};
use binutils::vadnu::VadnuConfig;
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
    /// Inspect or modify daemon for auto-syncing
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
// TODO: run daily; see ⬇️
// TODO: generate plist; see <https://chatgpt.com/c/37dbb44c-639d-458c-a94d-06a0fb481db4>
fn main() -> Result<()> {
    let args = CommandArgs::parse();

    init_logging(&LoggingOptions {
        verbose: args.verbose,
    })?;

    latest_bin::ensure_latest_bin()?;

    trace!("main()");

    let config = config_from_args(&args)?;

    match &args.subcommand {
        VadnuCommand::Sync => sync(&config),
        VadnuCommand::Daemon(daemon_args) => daemon(daemon_args, &config),
    }
}

fn config_from_args(args: &CommandArgs) -> Result<VadnuConfig> {

    let home = env_home()?;

    let vadnu_dir = args
        .vadnu_dir
        .clone()
        .unwrap_or(format!("{}/docs/vadnu", home));
    let rsync_dir = args
        .rsync_dir
        .clone()
        .unwrap_or("/Volumes/hjdivad.j/docs/vadnu/linkedin".to_string());
    let sync_path = args.sync_path.clone();

    Ok(VadnuConfig {
        vadnu_dir: vadnu_dir.into(),
        rsync_dir: rsync_dir.into(),
        sync_path,
    })
}


fn daemon(args: &DaemonArgs, vadnu_config: &VadnuConfig) -> Result<()> {
    let plist_file_path: PathBuf = format!(
        "{}/Library/LaunchAgents/gg.hamilton.vadnu_sync.plist",
        env_home()?
    )
    .into();

    match args.subcommand {
        DaemonCommand::Show => show_daemon(),
        DaemonCommand::Install => install_daemon(&plist_file_path, vadnu_config),
        DaemonCommand::Uninstall => uninstall_daemon(&plist_file_path),
    }
}
