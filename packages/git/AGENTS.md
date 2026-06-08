# Git Package

- This package contains personal Git configuration shared across many machines.
- `config`, `ignore`, and `attributes` are symlinked into `$HOME/.config/git/`.
- Machine-local Git config is included from `$HOME/.gitconfig.local`.
- Put simple shared aliases in `config` under `[alias]`.
- Put complicated Git commands in `bin/git-*` scripts so Git exposes them as subcommands, e.g. `bin/git-pu` for `git pu`.
