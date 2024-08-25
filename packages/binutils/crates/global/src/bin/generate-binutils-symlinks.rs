use anyhow::Result;
use tracing::debug;
use tracing_subscriber::EnvFilter;

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    latest_bin::ensure_latest_bin()?;

    let crate_root = latest_bin::get_crate_root()?;
    debug!("crate_root: {}", crate_root.display());
    global::build_utils::generate_symlinks(Some(crate_root))?;

    Ok(())
}
