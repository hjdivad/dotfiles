-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local term = require("config/auto/terminal")
local fold = require("config/auto/folding")

local function augroup(name)
  return vim.api.nvim_create_augroup("hjd_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("disable_session_persistence"),
  pattern = { "gitcommit" },
  callback = function()
    require("persistence").stop()
  end,
})

local ft_group = vim.api.nvim_create_augroup("hjdivad_ft", { clear=true })

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*.code-workspace",
  group = ft_group,
  callback = function()
    -- TODO: need to configure null-ls to pass `--parser=json` to prettier for this buffer (or like, always?)
    vim.bo.filetype = 'json'
  end,
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = ".commitlintrc.json",
  group = ft_group,
  callback = function()
    require('luasnip').filetype_extend('json', { 'commitlint' })
  end,
})

term.setup()
fold.setup()
