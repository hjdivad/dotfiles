-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- disable right-splitting from lazyvim
vim.opt.splitright = false

-- remote terminal, yank to client clipboard.
-- Requires client to have configured remote port forwarding for ssh and agent forwarding
-- Requires server config to have a host configuration named "client"
--
-- Obviously only do this if you trust the server.
--
-- @example
--
--  # $client/.ssh/config
--  Host remote
--    HostName        some.remote.server
--    # forward remote port 8855 to the local sshd port (default 22)
--    RemoteForward   :8855 :22
--    # forward agent so that we can copy to clipboard without prompting
--    ForwardAgent    yes
--
--  Host client
--  # $server/.ssh/config
--    HostName        localhost
--    Port            8855
--
-- This configuration assumes there are commands `pbcopy` and `pbpaste` that will write to and read from the clipbboard, respectively.
if vim.env.SSH_TTY ~= nil or vim.env.SSH_CLIENT ~= nil then
  vim.g.clipboard = {
    name = "ssh-pbcopy",
    copy = { ["+"] = "ssh client pbcopy", ["*"] = "ssh client pbcopy" },
    paste = { ["+"] = "ssh client pbpaste", ["*"] = "ssh client pbpaste" },
    cache_enabled = true,
  }
end

pp = vim.pretty_print
