use anyhow::{Context, Result};
use serde::Serialize;
use shell::*;
use std::fs::OpenOptions;
use std::path::{Path, PathBuf};
use tracing::debug;

use super::util::{env_home, xdg_error_path, xdg_log_path};
use super::VadnuConfig;

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

pub fn show_daemon() -> Result<()> {
    let in_launchctl = sh_q!(r#"launchctl list | rg gg.hamilton.vadnu_sync"#)?;
    if in_launchctl {
        println!("gg.hamilton.vadnu_sync loaded in launchctl");
    } else {
        println!("gg.hamilton.vadnu_sync not found in launchctl");
    }

    Ok(())
}

pub fn install_daemon( vadnu_config: &VadnuConfig) -> Result<()> {
    let plist_file_path = get_plist_file_path()?;

    write_plist(&plist_file_path, vadnu_config)?;

    debug!(
        "bootstrapping {} in launchctl",
        &plist_file_path.to_string_lossy()
    );
    sh!(&format!(
        "launchctl bootstrap gui/$(id -u) {}",
        &plist_file_path.to_string_lossy()
    ))?;

    println!("daemon installed");

    Ok(())
}

pub fn uninstall_daemon() -> Result<()> {
    // let plist_file_path = get_plist_file_path()?;

    Ok(())
}

fn get_plist_file_path() -> Result<PathBuf> {
    let plist_file_path: PathBuf = format!(
        "{}/Library/LaunchAgents/gg.hamilton.vadnu_sync.plist",
        env_home()?
    )
    .into();

    Ok(plist_file_path)
}

fn write_plist(plist_file_path: &Path, vadnu_config: &VadnuConfig) -> Result<()> {
    debug!("Writing plist: {}", &plist_file_path.to_string_lossy());

    let label = "gg.hamilton.vadnu_sync";
    let binary_path = std::env::current_exe()?;
    // TODO: set args from `vadnu_config`
    let args = vec!["sync", "-vv"];
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
        .truncate(false)
        .write(true)
        .open(plist_file_path)?;
    plist::to_writer_xml(file, &launch_config).context("Writing plist XML")?;

    Ok(())
}
