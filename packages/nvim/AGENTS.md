# Neovim Package

- This is a LazyVim-based Neovim config. Follow LazyVim conventions for plugin specs and options.
- Lua tests live in `tests/`, usually mirroring modules under `lua/` with `*_spec.lua` files.
- For Neovim behavior changes, add or update tests in `tests/`.
- Run `mise run test:nvim` from the repo root before committing Neovim code changes.
- Keep custom config in `lua/config/`, plugin specs in `lua/plugins/`, and personal modules in `lua/hjdivad/`.
