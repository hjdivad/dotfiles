pub mod sync;
pub mod daemon;
// TODO: can do this without pub mod?
pub mod util;

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

#[derive(Debug)]
pub struct VadnuConfig {
    pub vadnu_dir: PathBuf,
    pub rsync_dir: PathBuf,
    pub sync_path: Option<String>,
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

