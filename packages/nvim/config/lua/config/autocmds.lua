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

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "*.code-workspace",
  group = vim.api.nvim_create_augroup("hjdivad_ft", { clear=true }),
  callback = function()
    -- TODO: need to configure null-ls to pass `--parser=json` to prettier for this buffer (or like, always?)
    vim.bo.filetype = 'json'
  end,
})

term.setup()
fold.setup()
