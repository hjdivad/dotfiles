-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("hjdivad_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("disable_session_persistence"),
  pattern = { "gitcommit" },
  callback = function()
    require("persistence").stop()
  end,
})

local terminal_setup = augroup("terminal_setup")

vim.api.nvim_create_autocmd({  "BufWinEnter", "TermOpen" }, {
  pattern = "term://*",
  group = terminal_setup,
  callback = function()
    vim.cmd("startinsert")
  end,
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
  pattern = "term://*",
  group = terminal_setup,
  callback = function()
    -- when creating a new window from a terminal, we'll WinEnter from the old
    -- terminal before switching to [No Name] and then opening a new terminal
    -- we don't want to startinsert while we're on [No Name], but rather wait
    -- until we've made it into the terminal
    vim.schedule(function ( )
      if vim.startswith(vim.api.nvim_buf_get_name(0), "term://") then
        vim.cmd("startinsert")
      end
    end)
  end,
})


vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_setup,
  callback = function()
    local win_id = vim.api.nvim_get_current_win()
    local win = vim.wo[win_id]

    win.number = false
    win.relativenumber = false
    win.winfixwidth = true

    -- TODO: calculate window width
    vim.api.nvim_win_set_width(win_id, 100)
  end,
})
