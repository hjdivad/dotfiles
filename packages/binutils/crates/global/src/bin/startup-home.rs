use binutils::tmux::{maybe_attach_tmux, startup_tmux, TmuxKnowledge};
use clap::Parser;
use std::env;

#[macro_use]
extern crate binutils;

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

impl binutils::tmux::Options for StartupHome {
    fn is_dry_run(&self) -> bool {
        self.dry_run
    }

    fn is_debug(&self) -> bool {
        self.debug
    }

    fn should_attach(&self) -> Option<bool> {
        self.attach
    }
}

// TODO: switch to [rob's
// version](https://github.com/rwjblue/dotfiles/blob/master/binutils/src/tmux.rs)
// TODO: and pull compile_binutils &c. from other startup
// TODO: also move the domain-specific stuff to its own package root
// TODO: including its own globals?
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
            ["dotfiles", "{home}/src/github/hjdivad/dotfiles", ["nvim"]],
            ["rwjblue/dotvim", "{home}/src/github/rwjblue/dotvim", ["nvim"]],
            ["binutils", "{home}/src/github/hjdivad/dotfiles/packages/binutils/crates/global", ["nvim"]]
        ],
        // ud:macros
        [
            "💪 ud_macros",
            ["💪 ud_macros", "{home}/src/hjdivad/ud_macros", ["nvim"]],
            ["sandbox-kotlin", "{home}/src/hjdivad/sandbox-kotlin", ["nvim"]],
            ["sandbox-android", "{home}/src/hjdivad/sandbox-android", ["nvim"]],
            ["sandbox-android2", "{home}/src/hjdivad/sandbox-android", ["nvim"]],
            ["kotlin-language-server", "{home}/src/fcwd/kotlin-language-server", ["nvim"]]
        ],
        // montoya.nvim
        [
            "montoya",
            ["montoya", "{home}/src/github/malleatus/montoya.nvim", ["nvim"]],
            ["montoya", "{home}/src/github/malleatus/montoya.nvim", ["nvim"]]
        ]
    ];

    let mut tmux = TmuxKnowledge::default();

    startup_tmux(startup_config, &options, &mut tmux);
    maybe_attach_tmux(&options, "todos");

    if options.debug {
        println!("{:?}", tmux);
    }
}
