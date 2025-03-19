#!/usr/bin/env -S nvim -l

-- setting this env will override all XDG paths
vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md>
-- :lua MiniTest.run_file()
-- :lua MiniTest.run_at_location()
-- TODO: update tests to use MiniTest.new_child_neovim(); right now running the
-- map_stack tests inside neovim messes up the parent instance
require("lazy.minit").setup({
  -- pass spec = {} -- LazySpec[] to load specs for the tests
})
