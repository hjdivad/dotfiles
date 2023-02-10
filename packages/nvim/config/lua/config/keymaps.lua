-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local ks = vim.keymap.set

-- delete default neovim mapping of Y to "$ (i.e. end of line vs whole line)
vim.keymap.del("n", "Y", {})

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

ks("n", "<leader><leader>", "<cmd>nohl | checktime<cr>", { desc = "Clear highlights" })

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
