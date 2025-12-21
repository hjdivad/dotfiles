# Neovim Agent Notes

Quick orientation for this `packages/nvim` tree.

## Structure
- `init.lua` bootstraps the Neovim config.
- `lua/config/*` holds core config modules (keymaps, options, zellij, etc.).
- `lua/hjdivad/*` contains utility modules used by config and tests.
- `lua/plugins/*` and `lua/plugins/extras/*` are LazyVim plugin specs.
- `after/` is for filetype-specific config.
- `overrides/` and `queries/` include Treesitter overrides/queries.
- `snippets/` and `spell/` are user snippets and spell files.

## Tests
- Specs live in `packages/nvim/tests/hjdivad/*_spec.lua`.
- Tests use `luassert` and run inside Neovim; see `packages/nvim/tests/minit.lua`.
- Patterns: tests often stub `vim.fn`/`vim.system` (example: `packages/nvim/tests/hjdivad/git_spec.lua`).
- Run tests with: `mise run test:nvim --offline`

## Conventions
- Prefer `vim.system` for external commands in Lua modules (see `packages/nvim/lua/hjdivad/tmux.lua`).
- Modules under `lua/config/*` usually return a table of functions with minimal state.
- Keep Lua edits ASCII unless a file already uses Unicode.

## Handy Files
- `packages/nvim/lazyvim.json` and `packages/nvim/lazy-lock.json` track plugin config/lock.
- `packages/nvim/stylua.toml` defines formatting rules.
