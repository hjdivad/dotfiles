pub mod sync;
pub mod agent;
pub mod util;

use std::path::PathBuf;

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

