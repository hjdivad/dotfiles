-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local LazyVimUtil = require("lazyvim.util")

local ks = vim.keymap.set
local existing_keymaps_lhs = {}
local kd = function(mode, lhs)
  local normalized_lhs = string.gsub(lhs, "<leader>", vim.g.mapleader)
  local km_lhs = existing_keymaps_lhs[mode]
  if not km_lhs then
    local km = vim.api.nvim_get_keymap(mode)
    km_lhs = vim.tbl_map(function(item)
      return item.lhs
    end, km)
    existing_keymaps_lhs[mode] = km_lhs
  end

  if vim.tbl_contains(km_lhs, normalized_lhs) then
    vim.keymap.del(mode, lhs)
  end
end

-- delete default neovim mapping of Y to "$ (i.e. end of line vs whole line)
kd("n", "Y")
-- delete s & x mappings to train myself to use c (change) and d (delete)
ks({ "n", "v" }, "x", "", { nowait = true })
ks({ "n", "v" }, "X", "", { nowait = true })

-- see LazyVim's keymaps
-- $HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua
-- delete bad keymaps from LazyVim
kd("n", "<C-H>")
kd("n", "<C-L>")
kd("n", "<C-J>")
kd("n", "<C-K>")
kd("n", "<C-Up>")
kd("n", "<C-Down>")
kd("n", "<C-Left>")
kd("n", "<C-Right>")
kd("n", "<M-j>")
kd("n", "<M-k>")
kd("i", "<M-j>")
kd("i", "<M-k>")
kd("v", "<M-j>")
kd("v", "<M-k>")
kd("n", "H")
kd("n", "L")
kd("n", "[b")
kd("n", "]b")
kd("n", "<leader>ub")
kd("n", "<leader>ut")
kd("n", "<leader>bb")
kd("n", "<leader>`")
kd("n", "<Esc>")
kd("i", "<Esc>")
kd("n", "<leader>ur")
kd("n", "<leader>|")
kd("n", "<leader>K")
kd("n", "<leader>bl")
kd("n", "<leader>br")
kd("n", "<leader>bo")
kd("n", "<leader>L")
kd("n", "<leader>uF")
kd("n", "<leader>uT")
kd("n", ";")
kd("t", "<C-l>")
kd("t", "<C-L>")
kd("t", "<C-K>")
kd("t", "<C-J>")

-- I have no idea what map("n", "gw", "*N") is supposed to do
kd("n", "gw")
kd("x", "gw")

-- unsure about these; maybe restore them
kd("i", ",")
kd("i", ".")
kd("i", ";")

-- delete more bad keymaps
kd("i", "<C-S>")
kd("v", "<C-S>")
kd("n", "<C-S>")
kd("s", "<C-S>")

kd("n", "<leader>l") -- lazy
kd("n", "<leader>fn") -- new file
kd("n", "<leader>xl") -- location list
kd("n", "<leader>xq") -- quickfix list

kd("n", "<leader>uf") -- toggle format on save
kd("n", "<leader>us") -- toggle spelling
kd("n", "<leader>uw") -- toggle word wrap
kd("n", "<leader>ul") -- toggle relative number
kd("n", "<leader>ud") -- toggle diagnostics
kd("n", "<leader>uc") -- toggle conceal
kd("n", "<leader>un") -- delete notifications
kd("n", "<leader>gg") -- lazygit cwd=get_root()
kd("n", "<leader>gG") -- lazygit
kd("n", "<leader>qq") -- quit

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  kd("n", "<leader>ui") -- inspect pos; no idea what this does
end

kd("n", "<leader>ft") -- floating terminal cwd=get_root()
kd("n", "<leader>fT") -- floating terminal
kd("n", "<leader>ww") -- other window
kd("n", "<leader>wd") -- delete window
kd("n", "<leader>w-") -- split below
kd("n", "<leader>w|") -- split right
kd("n", "<leader>-") -- split below
kd("n", "<leader><Tab>l") -- last tab
kd("n", "<leader><Tab>f") -- first tab
kd("n", "<leader><Tab><Tab>") -- new tab
kd("n", "<leader><Tab>]") -- next tab
kd("n", "<leader><Tab>d") -- delete tab
kd("n", "<leader><Tab>[") -- previous tab

-- add keymaps

-- tab navigation
ks("n", "<leader>1", "1gt", { desc = "go to tab 1" })
ks("n", "<leader>2", "2gt", { desc = "go to tab 2" })
ks("n", "<leader>3", "3gt", { desc = "go to tab 3" })
ks("n", "<leader>4", "4gt", { desc = "go to tab 4" })
ks("n", "<leader>5", "5gt", { desc = "go to tab 5" })
ks("n", "<leader>6", "6gt", { desc = "go to tab 6" })
ks("n", "<leader>7", "7gt", { desc = "go to tab 7" })
ks("n", "<leader>8", "8gt", { desc = "go to tab 8" })
ks("n", "<leader>9", "9gt", { desc = "go to tab 9" })
ks("n", "<leader>0", "0gt", { desc = "go to tab 10" })
ks({"n","t"}, "<F1>", "<Cmd>tabn 1<cr>", { desc = "go to tab 1" })
ks({"n","t"}, "<F2>", "<Cmd>tabn 2<cr>", { desc = "go to tab 2" })
ks({"n","t"}, "<F3>", "<Cmd>tabn 3<cr>", { desc = "go to tab 3" })
ks({"n","t"}, "<F4>", "<Cmd>tabn 4<cr>", { desc = "go to tab 4" })
ks({"n","t"}, "<F5>", "<Cmd>tabn 5<cr>", { desc = "go to tab 5" })
ks({"n","t"}, "<F6>", "<Cmd>tabn 6<cr>", { desc = "go to tab 6" })
ks({"n","t"}, "<F7>", "<Cmd>tabn 7<cr>", { desc = "go to tab 7" })
ks({"n","t"}, "<F8>", "<Cmd>tabn 8<cr>", { desc = "go to tab 8" })
ks({"n","t"}, "<F9>", "<Cmd>$tabn<cr>", { desc = "go to the last tab page" })
-- <Cmd>0 reserved for restoring text size

ks("n", "<m-;>", ":lua =", { desc = "lua cmdline" })
ks("n", "<c-n>", ":lua =require('noice').redirect([[]])<Left><Left><Left>", { desc = "noice cmdline" })

ks("n", "<c-g>", function()
  require("noice").redirect("file")
end, { desc = "show :file in popup" })

ks("n", "ga", function()
  require("noice").redirect("ascii")
end, { desc = "show :ascii in popup" })

ks(
  "n",
  "<leader><leader>",
  "<cmd>nohl | diffupdate | checktime<cr>",
  { desc = "Redraw / clear hlsearch / checktime / diff update" }
)

local terminal = function()
  require('snacks').terminal()
end
ks("n", "<c-t>", terminal, { desc = "Terminal (root dir)" })

local clipboard_reg
if vim.fn.has("clipboard") then
  clipboard_reg = "+"
else
  clipboard_reg = '"'
end

ks("n", "<leader>yf", function()
  vim.fn.setreg(clipboard_reg, vim.fn.expand("%"))
end, { desc = "yank path (buf) to clipboard" })
ks("n", "<leader>yF", function()
  vim.fn.setreg(clipboard_reg, vim.fn.expand("%:p"))
end, { desc = "yank absolute path (buf) to clipboard" })

ks("t", "<c-g><c-g>", [[<c-\><c-n>]], { desc = "Terminal goto normal mode" })
ks("t", "<c-w>h", [[<c-\><c-n><c-w>h]], { desc = "win-left (terminal)" })
ks("t", "<c-w><c-h>", [[<c-\><c-n><c-w>h]], { desc = "win-left (terminal)" })
ks("t", "<c-w>j", [[<c-\><c-n><c-w>j]], { desc = "win-down (terminal)" })
ks("t", "<c-w><c-j>", [[<c-\><c-n><c-w>j]], { desc = "win-down (terminal)" })
ks("t", "<c-w>k", [[<c-\><c-n><c-w>k]], { desc = "win-up (terminal)" })
ks("t", "<c-w><c-k>", [[<c-\><c-n><c-w>k]], { desc = "win-up (terminal)" })
ks("t", "<c-w>l", [[<c-\><c-n><c-w>l]], { desc = "win-right (terminal)" })
ks("t", "<c-w><c-l>", [[<c-\><c-n><c-w>l]], { desc = "win-right (terminal)" })
ks("t", "<c-w>n>", [[<c-\><c-n><c-w>n<Cmd>terminal<cr>]], { desc = "win new (terminal)" })
ks("t", "<c-w><c-n>", [[<c-\><c-n><c-w>n<Cmd>terminal<cr>]], { desc = "win new (terminal)" })
ks("t", "<c-w>v>", [[<c-\><c-n><c-w>v<Cmd>terminal<cr>]], { desc = "win new (vertical terminal)" })
ks("t", "<c-w><c-v>", [[<c-\><c-n><c-w>v<Cmd>terminal<cr>]], { desc = "win new (vertical terminal)" })
ks("t", "<c-w>c", [[<c-\><c-n><c-w>c]], { desc = "win-right (terminal)" })
ks("t", "<c-w><c-c>", [[<c-\><c-n><c-w>c]], { desc = "win-right (terminal)" })

ks("n", "<leader>uld", "<Cmd>DapShowLog<Cr>", { desc = "show logs (DAP)" })
-- <c-w>o "only this window" by default closes all other windows, which I find useless
-- OTOH, toggling window zoom is very useful
Snacks.toggle.zoom():map("<c-w>o"):map("<leader>uZ")


ks("n", "<leader>uL", function()
  LazyVimUtil.news.changelog()
end, { desc = "LazyVim Changelog" })
ks("n", "<leader>up", "<Cmd>Lazy<CR>", { desc = "plugin management with lazy" })

ks("n", "u", "<cmd>silent! u<cr>", {})
ks("n", "<c-r>", "<cmd>silent! redo<cr>", {})

-- use ⌘-s to save to avoid the confirmation dialog
ks("n", "<a-s>", "<cmd>silent! wall<cr>", {})
