use clap::Parser;
use std::collections::HashMap;
use std::env;
use std::os::unix::process::CommandExt;
use std::process::Command;
use std::str;

/// Set up standard tmux sessions for home.
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct StartupHome {
    /// Print command instead of executing them
    #[arg(long)]
    dry_run: bool,

    /// Print debugging information
    #[arg(long)]
    debug: bool,

    /// Whether to attach to todos after starting up.
    /// Defaults to true unless $TMUX is set
    #[arg(long)]
    attach: Option<bool>,
}

#[derive(Default, Debug)]
struct TmuxKnowledge {
    sessions: Vec<String>,
    /// A map of (session_name, Vec<window_name>) tuples
    session_windows: HashMap<String, Vec<String>>,
}

macro_rules! s {
    ($e:expr) => {
        $e.to_string()
    };
}


macro_rules! config {
    ($([$session:expr, $([$window:expr, $path:expr, $commands:expr]),*]),*) => {{
        let mut configs = Vec::new();
        let home = env::var("HOME").unwrap_or_else(|_| "~".to_string());

        $(
            $(
                // Directly use the `home` variable with `replace` to handle the "{home}" placeholder
                let path_with_home = $path.replace("{home}", &home);
                configs.push(win(
                    s![$session],
                    s![$window],
                    path_with_home,
                    $commands.iter().map(|&cmd| s![cmd]).collect::<Vec<_>>(),
                ));
            )*
        )*

        configs
    }};
}

pub fn main() {
    let options = StartupHome::parse();

    let startup_config = config![
        // todos session
        [
            "todos",
            ["todos", "{home}/docs/vadnu/home", ["nvim"]],
            ["reference", "{home}/docs/vadnu/home/ref", ["nvim"]],
            ["journal", "{home}/docs/vadnu/home/journal", ["nvim"]]
        ],
        // dotfiles session
        [
            "dotfiles",
            ["dotfiles", "{home}/src/hjdivad/dotfiles", ["nvim"]]
        ]
    ];

    let mut tmux = TmuxKnowledge::default();

    startup_tmux(startup_config, &options, &mut tmux);
    maybe_attach_tmux(&options, "todos");

    if options.debug {
        println!("{:?}", tmux);
    }
}

fn maybe_attach_tmux(options: &StartupHome, session_name: &str) {
    let should_attach = options
        .attach
        .unwrap_or_else(|| env::var("TMUX").map(|v| v.is_empty()).unwrap_or(true));

    if !should_attach {
        return;
    }

    let mut attach_cmd = Command::new("tmux");
    attach_cmd.args(vec!["attach", "-t", session_name]);

    exec_command(attach_cmd, options);
}

fn startup_tmux(config: Vec<TmuxWindowSetup>, options: &StartupHome, tmux: &mut TmuxKnowledge) {
    for win_config in config {
        ensure_session(&win_config, options, tmux);
        ensure_window(&win_config, options, tmux);
    }
}

fn ensure_session(win_config: &TmuxWindowSetup, options: &StartupHome, tmux: &mut TmuxKnowledge) {
    if session_exists(win_config, tmux) {
        return;
    }

    let mut cmd_new_session = Command::new("tmux");
    cmd_new_session.args([
        "new-session",
        "-s",
        &win_config.session_name,
        "-n",
        &win_config.window_name,
        "-d",
    ]);

    let cmd_window_initial_cmds = build_window_initial_cmds(win_config);

    run_command(cmd_new_session, options);
    run_command(cmd_window_initial_cmds, options);

    tmux.sessions.push(win_config.session_name.clone());
}

fn ensure_window(win_config: &TmuxWindowSetup, options: &StartupHome, tmux: &mut TmuxKnowledge) {
    ensure_windows_loaded(win_config, tmux);

    let TmuxWindowSetup {
        session_name,
        window_name,
        ..
    } = win_config;

    if window_exists(win_config, tmux) {
        // our work here is done
        return;
    }

    if options.debug {
        println!("{:?}", tmux);
    }
    let session_windows = tmux
        .session_windows
        .get_mut(session_name)
        .expect("session_windows should be loaded");

    let window_index = session_windows.len() + 1;
    if options.debug {
        println!("window_index={:?}", window_index);
    }

    let mut cmd_new_window = Command::new("tmux");
    cmd_new_window.args([
        "new-window",
        "-t",
        &format!("{}:{}", session_name, window_index),
        "-n",
        &window_name,
        "-d",
    ]);

    let cmd_window_initial_cmds = build_window_initial_cmds(win_config);

    run_command(cmd_new_window, options);
    run_command(cmd_window_initial_cmds, options);

    session_windows.push(window_name.clone());
}

fn build_window_initial_cmds(win_config: &TmuxWindowSetup) -> Command {
    let mut cmd_window_initial_cmd = Command::new("tmux");
    let mut args = vec![
        s!["send-keys"],
        s!["-t"],
        win_config.window_specifier(),
        format!("cd \"{}\"", win_config.cwd),
        s!["Enter"],
    ];
    for cmd in &win_config.startup_cmds {
        args.push(format!("\"{}\"", cmd));
        args.push("Enter".to_string());
    }
    cmd_window_initial_cmd.args(args);

    cmd_window_initial_cmd
}

fn session_exists(win_config: &TmuxWindowSetup, tmux: &mut TmuxKnowledge) -> bool {
    let TmuxWindowSetup { session_name, .. } = win_config;

    ensure_sessions_loaded(tmux);
    tmux.sessions.contains(session_name)
}

fn window_exists(win_config: &TmuxWindowSetup, tmux: &mut TmuxKnowledge) -> bool {
    let TmuxWindowSetup {
        window_name,
        session_name,
        ..
    } = win_config;

    ensure_windows_loaded(win_config, tmux);
    tmux.session_windows
        .get(session_name)
        .map(|session_windows| session_windows.contains(window_name))
        .unwrap_or(false)
}

fn ensure_windows_loaded(win_config: &TmuxWindowSetup, tmux: &mut TmuxKnowledge) {
    ensure_sessions_loaded(tmux);

    let TmuxWindowSetup { session_name, .. } = win_config;

    if tmux.session_windows.get(session_name).is_some() {
        // session already loaded
        return;
    }

    let output = Command::new("tmux")
        .args(["list-windows", "-t", session_name, "-F", "#{window_name}"])
        .output()
        .expect("Couldn't load windows; tmux ls failed");

    let output_str =
        str::from_utf8(&output.stdout).expect("tmux list-windows produced non-utf8 output");

    let session_windows: Vec<String> = output_str
        .split('\n')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();

    tmux.session_windows
        .insert(session_name.to_string(), session_windows);
}

fn ensure_sessions_loaded(tmux: &mut TmuxKnowledge) {
    if !tmux.sessions.is_empty() {
        // sessions already loaded
        return;
    }

    let output = Command::new("tmux")
        .args(["ls", "-F", "#{session_name}"])
        .output()
        .expect("Couldn't load sessions; tmux ls failed");

    let output_str = str::from_utf8(&output.stdout).expect("tmux ls produced non-utf8 output");

    let sessions: Vec<String> = output_str
        .split('\n')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();

    tmux.sessions.extend(sessions);
}

fn exec_command(mut cmd: Command, opts: &StartupHome) {
    if opts.dry_run {
        println!("{:?}", cmd);
        return;
    }

    cmd.exec();
}

fn run_command(mut cmd: Command, opts: &StartupHome) {
    if opts.dry_run {
        println!("{:?}", cmd);
        return;
    }

    let _ = cmd
        .output()
        .map_err(|err| println!("Error executing cmd\n{}", err));
}

struct TmuxWindowSetup {
    session_name: String,
    window_name: String,
    cwd: String,
    startup_cmds: Vec<String>,
}

impl TmuxWindowSetup {
    fn window_specifier(&self) -> String {
        format!("{}:{}", self.session_name, self.window_name)
    }
}

fn win(
    session_name: String,
    window_name: String,
    cwd: String,
    startup_cmds: Vec<String>,
) -> TmuxWindowSetup {
    TmuxWindowSetup {
        session_name,
        window_name,
        cwd,
        startup_cmds,
    }
}
