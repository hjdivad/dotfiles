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

local ft_group = vim.api.nvim_create_augroup("hjdivad_ft", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.code-workspace",
  group = ft_group,
  callback = function()
    -- TODO: need to configure null-ls to pass `--parser=json` to prettier for this buffer (or like, always?)
    vim.bo.filetype = "json"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = { ".swcrc" },
  group = ft_group,
  callback = function()
    -- TODO: need to configure null-ls to pass `--parser=json` to prettier for this buffer (or like, always?)
    vim.bo.filetype = "json"
    require("luasnip").filetype_extend("json", { "swc" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = ".commitlintrc.json",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("json", { "commitlint" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { ".lazy.lua", "**/nvim/config/lua/plugins/**/*.lua" },
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("lua", { "lazyvim" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = ".markdownlintrc",
  group = ft_group,
  callback = function()
    vim.bo.filetype = "json"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = ".eslintrc.json",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("json", { "eslint" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "Cargo.toml",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("toml", { "cargo" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "Taskfile.yml",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("yaml", { "taskfile" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "vite.config.ts",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("typescript", { "vite-config" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*_spec.lua",
  group = ft_group,
  callback = function()
    require("luasnip").filetype_extend("lua", { "plenary" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = { "typescriptreact" },
  callback = function()
    require("luasnip").filetype_extend("typescriptreact", { "typescript" })
  end,
})

term.setup()
fold.setup()


-- NOTE: local_config is symlinked in from local-dotfiles to allow for local
-- system specific customizations
-- see: https://github.com/malleatus/shared_binutils/blob/master/global/src/bin/setup-local-dotfiles.rs
require("local_config.config.autocmds")
