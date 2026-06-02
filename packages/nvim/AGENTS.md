# Neovim Package

- This is a LazyVim-based Neovim config. Follow LazyVim conventions for plugin specs and options.
- Lua tests live in `tests/`, usually mirroring modules under `lua/` with `*_spec.lua` files.
- The repo uses `mise` as its task runner. Run Neovim tests from the repo root with `mise run test:nvim`.
- Keep custom config in `lua/config/`, plugin specs in `lua/plugins/`, and personal modules in `lua/hjdivad/`.
