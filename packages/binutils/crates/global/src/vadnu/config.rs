use crate::vadnu::util::xdg_config_path;

use super::VadnuConfig;
use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::Path;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    /// Error indicating that vadnu_dir was not specified in either args or config
    #[error("vadnu-dir must be specified in either the arguments or the configuration file: {0}")]
    VadnuDirNotSpecified(String),

    /// Error indicating that rsync_dir was not specified in either args or config
    #[error("rsync-dir must be specified in either the arguments or the configuration file: {0}")]
    RsyncDirNotSpecified(String),
}

/// Saved defaults when running `vadnu-sync`
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct VadnuSyncConfig {
    /// Path to use for `--vadnu-dir` if not specified on the command line.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub vadnu_dir: Option<String>,

    /// Path to use for `--rsync-dir` if not specified on the command line.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rsync_dir: Option<String>,

    /// Path to use for `--sync-path` if not specified on the command line.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sync_path: Option<String>,
}

pub fn config_from_args(args: VadnuSyncConfig) -> Result<VadnuConfig> {
    let lua_config_path = xdg_config_path()?;
    let config = if lua_config_path.exists() {
        lua_config_utils::read_config::<VadnuSyncConfig>(lua_config_path.as_path())?
    } else {
        VadnuSyncConfig {
            vadnu_dir: None,
            rsync_dir: None,
            sync_path: None,
        }
    };

    let vadnu_dir = args
        .vadnu_dir
        .clone()
        .or(config.vadnu_dir.clone())
        .ok_or_else(|| {
            anyhow::Error::new(Error::VadnuDirNotSpecified(
                lua_config_path.to_string_lossy().to_string(),
            ))
        })?;

    let rsync_dir = args
        .rsync_dir
        .clone()
        .or(config.rsync_dir.clone())
        .ok_or_else(|| {
            anyhow::Error::new(Error::RsyncDirNotSpecified(
                lua_config_path.to_string_lossy().to_string(),
            ))
        })?;

    Ok(VadnuConfig {
        vadnu_dir: Path::new(&vadnu_dir).to_path_buf(),
        rsync_dir: Path::new(&rsync_dir).to_path_buf(),
        sync_path: args.sync_path.or(config.sync_path),
    })
}

#[cfg(test)]
mod tests {
    use std::{env, fs, path::Path};

    use super::*;
    use tempfile::tempdir;

    fn set_up_test(config_contents: Option<&str>) -> Result<tempfile::TempDir> {
        let temp_dir = tempdir()?;
        let config_dir = temp_dir.path().join("config");
        fs::create_dir(&config_dir)?;

        unsafe { env::set_var("XDG_CONFIG_HOME", &config_dir) };

        let config_file_path = config_dir.join("vadnu-sync.lua");
        if let Some(contents) = config_contents {
            fs::write(config_file_path, contents)?;
        }

        Ok(temp_dir)
    }

    #[test]
    fn test_config_from_args_with_all_values() -> Result<()> {
        // Setup test with no config file
        let tmp_dir = set_up_test(None)?;

        let args = VadnuSyncConfig {
            vadnu_dir: Some("/path/to/vadnu_dir".to_string()),
            rsync_dir: Some("/path/to/rsync_dir".to_string()),
            sync_path: Some("/path/to/sync_path".to_string()),
        };

        let config = config_from_args(args.clone())?;

        assert_eq!(config.vadnu_dir, Path::new("/path/to/vadnu_dir"));
        assert_eq!(config.rsync_dir, Path::new("/path/to/rsync_dir"));
        assert_eq!(config.sync_path, args.sync_path);

        drop(tmp_dir);
        Ok(())
    }

    #[test]
    fn test_config_from_args_with_partial_values() -> Result<()> {
        // Setup test with a config file containing some values
        let config_contents = r#"
        return {
            vadnu_dir = "/default/vadnu_dir",
            rsync_dir = "/default/rsync_dir"
        }
        "#;
        let temp_dir = set_up_test(Some(config_contents))?;

        let args = VadnuSyncConfig {
            vadnu_dir: None,
            rsync_dir: Some("/path/to/rsync_dir".to_string()),
            sync_path: None,
        };

        let config = config_from_args(args.clone())?;

        assert_eq!(config.vadnu_dir, Path::new("/default/vadnu_dir"));
        assert_eq!(config.rsync_dir, Path::new("/path/to/rsync_dir"));
        assert_eq!(config.sync_path, None);

        drop(temp_dir);
        Ok(())
    }

    #[test]
    fn test_config_from_args_with_no_values() -> Result<()> {
        // Setup test with a config file containing all default values
        let config_contents = r#"
        return {
            vadnu_dir = "/default/vadnu_dir",
            rsync_dir = "/default/rsync_dir",
            sync_path = "/default/sync_path",
        }
        "#;
        let temp_dir = set_up_test(Some(config_contents))?;

        let args = VadnuSyncConfig {
            vadnu_dir: None,
            rsync_dir: None,
            sync_path: None,
        };

        let config = config_from_args(args.clone())?;

        assert_eq!(config.vadnu_dir, Path::new("/default/vadnu_dir"));
        assert_eq!(config.rsync_dir, Path::new("/default/rsync_dir"));
        assert_eq!(config.sync_path, Some("/default/sync_path".to_string()));

        drop(temp_dir);
        Ok(())
    }

    #[test]
    fn test_config_from_args_missing_vadnu_dir() -> Result<()> {
        // Setup test with a config file that doesn't specify vadnu_dir
        let config_contents = r#"
        return {
            rsync_dir = "/default/rsync_dir",
        }
        "#;
        let temp_dir = set_up_test(Some(config_contents))?;

        let args = VadnuSyncConfig {
            vadnu_dir: None,
            rsync_dir: Some("/path/to/rsync_dir".to_string()),
            sync_path: None,
        };

        let result = config_from_args(args);

        let Err(err) = result else {
            panic!("Expected config_from_args() to error");
        };

        let Some(err) = err.downcast_ref::<Error>() else {
            panic!("Unexpected error: {:?}", err);
        };

        let Error::VadnuDirNotSpecified(_) = err else {
            panic!("Unexpected error: {:?}", err);
        };

        drop(temp_dir);
        Ok(())
    }

    #[test]
    fn test_config_from_args_missing_rsync_dir() -> Result<()> {
        // Setup test with a config file that doesn't specify rsync_dir
        let config_contents = r#"
        return {
            vadnu_dir = "/default/vadnu_dir"
        }
        "#;
        let temp_dir = set_up_test(Some(config_contents))?;

        let args = VadnuSyncConfig {
            vadnu_dir: Some("/path/to/vadnu_dir".to_string()),
            rsync_dir: None,
            sync_path: None,
        };

        let result = config_from_args(args);

        let Err(err) = result else {
            panic!("Expected config_from_args() to error");
        };

        let Some(err) = err.downcast_ref::<Error>() else {
            panic!("Unexpected error: {:?}", err);
        };

        let Error::RsyncDirNotSpecified(_) = err else {
            panic!("Unexpected error: {:?}", err);
        };

        drop(temp_dir);
        Ok(())
    }
}
