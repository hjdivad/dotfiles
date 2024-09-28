use anyhow::{Context, Result};
use std::fs::{self, OpenOptions};
use std::path::Path;
use std::{env, path::PathBuf};
use tracing_subscriber::fmt::time;
use tracing_subscriber::fmt::writer::{BoxMakeWriter, MakeWriterExt};
use tracing_subscriber::EnvFilter;
use xdg::BaseDirectories;


pub fn xdg_log_path() -> Result<PathBuf> {
    let xdg_dirs = BaseDirectories::with_prefix("binutils")?;
    xdg_dirs
        .place_state_file("vadnu-sync.log")
        .context("tried to compute XDG_STATE log path")
}

pub fn xdg_error_path() -> Result<PathBuf> {
    let xdg_dirs = BaseDirectories::with_prefix("binutils")?;
    xdg_dirs
        .place_state_file("vadnu-sync.err")
        .context("tried to compute XDG_STATE error log path")
}

pub struct LoggingOptions {
    pub verbose: u8
}

pub fn init_logging(options: &LoggingOptions) -> Result<()> {
    let mut env_filter =
        EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("off"));

    let log_level = match options.verbose {
        1 => Some("info"),
        2 => Some("debug"),
        3 => Some("trace"),
        _ => None,
    };

    if let Some(log_level) = log_level {
        env_filter = env_filter.add_directive(format!("binutils::vadnu={}", log_level).parse()?);
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

pub fn env_home() -> Result<String> {
    env::var("HOME").context("No $HOME - no idea what to do")
}
