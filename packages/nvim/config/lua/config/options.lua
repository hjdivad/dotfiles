-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Disable LazyVim format-on-save
vim.g.autoformat = false

-- disable right-splitting from lazyvim
vim.opt.splitright = false

vim.opt.spelllang = { "sv", "en_gb", "en_us" }
vim.opt.spellfile =
  { ".vimspell.utf.8", "~/.local/share/.nvim/spell/en.utf-8.add", "~/.local/share/.nvim/spell/sv.utf-8.add" }

vim.opt.swapfile = false

-- disable animations that cause slowness in things like `G`, `gg`, &c.
vim.g.snacks_animate = false

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

if vim.fn.has("nvim-0.9.0") == 1 then
  -- automatically run trusted .nvim.lua .nvimrc .exrc
  -- :trust <file> to trust
  -- :trust ++deny/++remove <file>
  vim.opt.exrc = true
end

-- global functions

---pretty print lua expression into a noice popup
--
---@param ... unknown
function pp(...)
  local args = { ... }
  require("noice").redirect(function()
    vim.print(unpack(args))
  end)
end

---noice inspect via redirection
---
---Example:
---
--- ```lua
--- -- run :version and display the results in a noice popup
--- ni('version')
--- ```
---
---@param ... unknown
function ni(...)
  require("noice").redirect(...)
end

-- add ~/.config/nvim/lua/config/local_options.lua for machine-specific configuration
-- e.g. vim.g.github_enterprise_urls = ["https://example.com"]
pcall(require, "config/local_options")
