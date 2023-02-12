-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local ks = vim.keymap.set
local kd = vim.keymap.del

local existing_keymaps_lhs = {}
function kd(mode, lhs)
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
    -- else
    --   print('no such keymap "' .. mode .. ": " .. lhs .. '"')
    --   vim.pretty_print("km_lhs(" .. mode .. ")", km_lhs)
  end
end

-- delete default neovim mapping of Y to "$ (i.e. end of line vs whole line)
kd("n", "Y", {})

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
kd("n", "<leader>bb")
kd("n", "<leader>`")
kd("n", "<Esc>")
kd("i", "<Esc>")
kd("n", "<leader>ur")

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
ks("n", "<leader>5", "6gt", { desc = "go to tab 6" })
ks("n", "<leader>5", "7gt", { desc = "go to tab 7" })
ks("n", "<leader>5", "8gt", { desc = "go to tab 8" })
ks("n", "<leader>5", "9gt", { desc = "go to tab 9" })
ks("n", "<leader>5", "0gt", { desc = "go to tab 10" })

ks("n", "<m-;>", ":lua ", { desc = "lua cmdline" })

ks(
  "n",
  "<leader><leader>",
  "<cmd>nohl | diffupdate | checktime<cr>",
  { desc = "Redraw / clear hlsearch / checktime / diff update" }
)

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

-- TODO: see https://github.com/rwjblue/dotvim/blob/f2dcf5d5964ccdd7dc2cdd008898af7a5eb110d5/lua/config/keymaps.lua#L20-L30
