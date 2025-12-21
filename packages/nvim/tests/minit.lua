#!/usr/bin/env -S nvim -l

local function __dirname()
  local fullpath = debug.getinfo(1,"S").source:sub(2)
  local dirname, filename = fullpath:match('^(.*/)([^/]-)$')

  return dirname, filename
end

-- setting this env will override all XDG paths
vim.env.LAZY_STDPATH = ".tests"

local bootstrap_path = __dirname() .. "../vendor/bootstrap.lua"

if vim.env.LAZY_OFFLINE ~= "true" then
  vim.fn.system("curl --silent https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua >" .. bootstrap_path)
end

loadfile(__dirname() .. "../vendor/bootstrap.lua")()


 -- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md>
 -- :lua MiniTest.run_file()
 -- :lua MiniTest.run_at_location()
 -- TODO: update tests to use MiniTest.new_child_neovim(); right now running the
 -- map_stack tests inside neovim messes up the parent instance
 require("lazy.minit").setup({
   -- pass spec = {} -- LazySpec[] to load specs for the tests
 })
