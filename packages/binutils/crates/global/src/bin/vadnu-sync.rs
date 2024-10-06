use std::io;

use anyhow::Result;
use binutils::vadnu::agent::{install_agent, show_agent, uninstall_agent, ShowAgentOptions};
use binutils::vadnu::config::{config_from_args, VadnuSyncConfig};
use binutils::vadnu::sync::sync;
use binutils::vadnu::util::{init_logging, LoggingOptions};
use binutils::vadnu::VadnuConfig;
use clap::{CommandFactory, Parser, Subcommand};
use clap_complete::generate;
use tracing::trace;

/// Sync the vadnu dir against rsync. Unspecified args are read from $HOME/.config/vadnu-sync.lua.
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct CommandArgs {
    /// The vadnu directory.
    #[arg(long)]
    vadnu_dir: Option<String>,

    /// The sync path within `vadnu`.
    #[arg(long)]
    sync_path: Option<String>,

    /// The rsync directory.
    #[arg(long)]
    rsync_dir: Option<String>,

    /// Print more. Can be specified up to 3 times (-vvv).
    #[arg(long, short = 'v', action = clap::ArgAction::Count)]
    verbose: u8,

    #[command(subcommand)]
    subcommand: VadnuCommand,
}

#[derive(Subcommand, Debug)]
enum VadnuCommand {
    /// Sync vadnu
    Sync,

    /// Inspect or modify agent for auto-syncing
    Agent(AgentArgs),

    /// Show the resolved config
    Config,

    /// Generate shell completions for vadnu-sync
    Completions(CompletionArgs),
}

#[derive(Parser, Debug)]
struct AgentArgs {
    #[command(subcommand)]
    subcommand: AgentCommand,
}

#[derive(Parser, Debug)]
struct CompletionArgs {
    #[arg(long, required = true)]
    shell: Option<clap_complete::Shell>,
}

#[derive(Subcommand, Debug)]
enum AgentCommand {
    /// Check whether the agent is installed
    Show(AgentShowArgs),
    /// Install the agent
    Install,
    /// Uninstall the agent
    Uninstall,
}

#[derive(Parser, Debug)]
struct AgentShowArgs {
    /// Print the entire plist if the daemon is loaded
    #[arg(long, short = 'p')]
    plist: bool,
}

fn main() -> Result<()> {
    latest_bin::ensure_latest_bin()?;

    let args = CommandArgs::parse();

    init_logging(&LoggingOptions {
        verbose: args.verbose,
    })?;

    trace!("main()");

    let config = config_from_args(VadnuSyncConfig {
        vadnu_dir: args.vadnu_dir.clone(),
        rsync_dir: args.rsync_dir.clone(),
        sync_path: args.sync_path.clone(),
    })?;

    match args.subcommand {
        VadnuCommand::Completions(args) => {
            let shell = args.shell.unwrap();
            generate(
                shell,
                &mut CommandArgs::command(),
                "vadnu-sync",
                &mut io::stdout(),
            );
            Ok(())
        }
        VadnuCommand::Config => show_config(&config),
        VadnuCommand::Sync => sync(&config),
        VadnuCommand::Agent(agent_args) => agent(agent_args, &config),
    }
}

fn agent(args: AgentArgs, vadnu_config: &VadnuConfig) -> Result<()> {
    match args.subcommand {
        AgentCommand::Show(show_args) => show_agent(ShowAgentOptions {
            print_plist: show_args.plist,
        }),
        AgentCommand::Install => install_agent(vadnu_config),
        AgentCommand::Uninstall => uninstall_agent(),
    }
}

fn show_config(config: &VadnuConfig) -> Result<()> {
    print!("{:#?}", config);

    Ok(())
}
