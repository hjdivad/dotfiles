// build.rs
use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());

    let mut build_sh_path = path.clone();
    build_sh_path.push("../../build.sh");
    build_sh_path = build_sh_path.canonicalize().unwrap();

    let mut file = File::create("src/codegen/build_sh_path.txt").unwrap();
    writeln!(file, "{}", build_sh_path.display()).unwrap();

    let mut projects_path = path.clone();
    projects_path.push("../project");
    projects_path = projects_path.canonicalize().unwrap();

    let mut file = File::create("src/codegen/project_root_path.txt").unwrap();
    writeln!(file, "{}", projects_path.display()).unwrap();
}
