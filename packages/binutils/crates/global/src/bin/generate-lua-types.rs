use clap::Parser;
use std::path::PathBuf;

use anyhow::Result;
use tracing_subscriber::EnvFilter;

/// Generate lua types for a given file's desearializable structs
#[derive(Parser, Debug)]
#[command()]
struct Args {
    /// Sets the input file (the rust file that contains the structs)
    #[arg(short, long, value_name = "FILE")]
    input: PathBuf,

    /// Sets the output file path (where the `.lua` type output should go)
    #[arg(short, long, value_name = "FILE")]
    output: PathBuf,
}

fn main() -> Result<()> {
    // Initialize tracing, use `info` by default
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    latest_bin::ensure_latest_bin()?;

    let args = Args::parse();

    lua_config_utils::lua_type_gen::process_file(args.input, args.output);

    Ok(())
}
