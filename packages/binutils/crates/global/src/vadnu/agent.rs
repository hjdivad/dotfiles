use anyhow::{Context, Result};
use serde::Serialize;
use shell::*;
use std::fs::{self, OpenOptions};
use std::path::{Path, PathBuf};
use tracing::debug;

use crate::vadnu::util::xdg_out_path;

use super::util::{env_home, xdg_error_path};
use super::VadnuConfig;

pub struct ShowAgentOptions {
    pub print_plist: bool
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

pub fn show_agent(show_args: ShowAgentOptions) -> Result<()> {
    let in_launchctl = sh_q!(r#"launchctl list | rg gg.hamilton.vadnu_sync"#)?;
    if in_launchctl {
        println!("gg.hamilton.vadnu_sync loaded in launchctl");

        if show_args.print_plist {
            print_plist()?;
        }
    } else {
        println!("gg.hamilton.vadnu_sync not found in launchctl");
    }

    Ok(())
}

pub fn print_plist() -> Result<()> {
    let file_path = get_plist_file_path()?;

    let contents = fs::read_to_string(&file_path)?;

    print!("{}", contents);

    Ok(())
}

pub fn install_agent(vadnu_config: &VadnuConfig) -> Result<()> {
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

    println!("agent installed");

    Ok(())
}

pub fn uninstall_agent() -> Result<()> {
    let plist_file_path = get_plist_file_path()?;

    debug!(
        "booting out {} in launchctl",
        &plist_file_path.to_string_lossy()
    );
    sh!(&format!(
        "launchctl bootout gui/$(id -u) {}",
        &plist_file_path.to_string_lossy()
    ))?;

    println!("agent uninstalled");

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
    let mut args = vec!["-vv".to_string()];
    let maybe_args = vec![
        (
            "--vadnu-dir".to_string(),
            Some(vadnu_config.vadnu_dir.clone().to_string_lossy().to_string()),
        ),
        ("--sync-path".to_string(), vadnu_config.sync_path.clone()),
        (
            "--rsync-dir".to_string(),
            Some(vadnu_config.rsync_dir.clone().to_string_lossy().to_string()),
        ),
    ];

    for (arg, value) in maybe_args {
        if let Some(value) = value {
            args.push(arg);
            args.push(value);
        }
    }

    args.push("sync".to_string());

    let hour = 2;
    let minute = 0;
    let stdout_path = xdg_out_path()?;
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

#[cfg(test)]
mod tests {
    use std::fs;

    use insta::assert_snapshot;
    use regex::Regex;
    use tempfile::NamedTempFile;

    use crate::vadnu::util;

    use super::*;

    fn clean_plist_contents(plist_contents: String) -> Result<String> {
        let home = util::env_home()?;
        let plist_contents = plist_contents.replace(&home, "$HOME");

        let re = Regex::new(r">.*target/debug/.*<").unwrap();
        let cleaned_contents = re.replace_all(&plist_contents, ">$$BIN<");

        Ok(cleaned_contents.to_string())
    }

    #[test]
    fn test_write_plist_with_sync_path() -> Result<()> {
        let plist_file = NamedTempFile::new()?;

        let config = VadnuConfig {
            vadnu_dir: "/Users/foo/docs/vadnu".into(),
            rsync_dir: "/Volumes/foo/sync".into(),
            sync_path: Some("bar".into()),
        };

        write_plist(plist_file.path(), &config)?;

        let plist_contents = fs::read_to_string(plist_file.path())?;
        let cleaned_plist = clean_plist_contents(plist_contents)?;

        assert_snapshot!(cleaned_plist, @r###"
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        	<key>Label</key>
        	<string>gg.hamilton.vadnu_sync</string>
        	<key>ProgramArguments</key>
        	<array>
        		<string>$BIN</string>
        		<string>-vv</string>
        		<string>--vadnu-dir</string>
        		<string>/Users/foo/docs/vadnu</string>
        		<string>--sync-path</string>
        		<string>bar</string>
        		<string>--rsync-dir</string>
        		<string>/Volumes/foo/sync</string>
        		<string>sync</string>
        	</array>
        	<key>StartCalendarInterval</key>
        	<dict>
        		<key>Hour</key>
        		<integer>2</integer>
        		<key>Minute</key>
        		<integer>0</integer>
        	</dict>
        	<key>StandardOutPath</key>
        	<string>$HOME/.local/state/binutils/vadnu-sync.out</string>
        	<key>StandardErrorPath</key>
        	<string>$HOME/.local/state/binutils/vadnu-sync.err</string>
        	<key>RunAtLoad</key>
        	<false/>
        </dict>
        </plist>
        "###);

        Ok(())
    }

    #[test]
    fn test_write_plist_with_no_sync_path() -> Result<()> {
        let plist_file = NamedTempFile::new()?;

        let config = VadnuConfig {
            vadnu_dir: "/Users/foo/docs/vadnu".into(),
            rsync_dir: "/Volumes/foo/sync".into(),
            sync_path: None,
        };

        write_plist(plist_file.path(), &config)?;

        let plist_contents = fs::read_to_string(plist_file.path())?;
        let cleaned_plist = clean_plist_contents(plist_contents)?;

        assert_snapshot!(cleaned_plist, @r###"
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        	<key>Label</key>
        	<string>gg.hamilton.vadnu_sync</string>
        	<key>ProgramArguments</key>
        	<array>
        		<string>$BIN</string>
        		<string>-vv</string>
        		<string>--vadnu-dir</string>
        		<string>/Users/foo/docs/vadnu</string>
        		<string>--rsync-dir</string>
        		<string>/Volumes/foo/sync</string>
        		<string>sync</string>
        	</array>
        	<key>StartCalendarInterval</key>
        	<dict>
        		<key>Hour</key>
        		<integer>2</integer>
        		<key>Minute</key>
        		<integer>0</integer>
        	</dict>
        	<key>StandardOutPath</key>
        	<string>$HOME/.local/state/binutils/vadnu-sync.out</string>
        	<key>StandardErrorPath</key>
        	<string>$HOME/.local/state/binutils/vadnu-sync.err</string>
        	<key>RunAtLoad</key>
        	<false/>
        </dict>
        </plist>
        "###);

        Ok(())
    }
}
