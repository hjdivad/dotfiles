---
name: git-review
description: Review and change this repo's Neovim git-review workflow. Use when working on <leader>eg, <leader>eG, Neo-tree git status review, gitsigns diff navigation, or packages/nvim/lua/hjdivad/neotree.lua.
---

# Git Review

This skill documents the current Neovim git-review feature and how agents should work on it.

## Current State

- `<leader>eg` is the default entrypoint. It opens a dedicated Neo-tree git status tab against the merge base of `HEAD` and the upstream branch.
- `<leader>eG` is the latest-commit entrypoint. It opens the same review UI for `HEAD~1..HEAD`.
- Both entrypoints are wired in `packages/nvim/lua/plugins/editor.lua`.
- The workflow implementation lives in `packages/nvim/lua/hjdivad/neotree.lua`.
- Tests live in `packages/nvim/tests/hjdivad/neotree_spec.lua`.

## Review UI Behavior

- The review tab is reused while it still exists and contains Neo-tree.
- `gd` on a file opens it in a right-side split and runs `gitsigns.diffthis()`.
- `<cr>` on a file opens it without starting a diff.
- `<C-j>` and `<C-k>` are temporary stacked mappings for next/previous changed-file navigation after opening a diff.

## Changing This Feature

- Keep keymap declarations in `editor.lua`; keep behavior in `hjdivad/neotree.lua`.
- Update or add tests in `neotree_spec.lua` for entrypoint behavior, gitsigns base changes, tab reuse, file opening, and navigation.
- Run Neovim tests from the repo root with `mise run test:nvim`.
- Update this skill when the feature's entrypoints, files, behavior, or test command changes.
