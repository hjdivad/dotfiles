---Copied from lazyvim/plugins/lsp/keymaps
---code is preserved except for keymaps
local M = {}

---@type PluginLspKeys
M._keys = nil

---@return (LazyKeys|{has?:string})[]
function M.get()
  -- TODO: copy & improve the lazy format fn here and in init
  -- this function always prefers formatting with null-ls for some reason.  
  -- see /Users/test/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/format.lua
  local format = require("lazyvim.plugins.lsp.format").format
  if not M._keys then
  ---@class PluginLspKeys
    -- stylua: ignore
    M._keys =  {
      { "<leader>gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
      { "<leader>gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "<leader>gt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto Type Definition" },
      { "<leader>gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "<leader>gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
      { "<leader>gc", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "Goto Incoming Calls" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "<c-h>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "<leader>dL", vim.diagnostic.open_float, desc = "Line Diagnostics" },
      { "<leader>dj", M.diagnostic_goto(true, "ERROR"), desc = "Next Error Diagnostic" },
      { "<leader>dk", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error Diagnostic" },
      { "<leader>dJ", M.diagnostic_goto(true), desc = "Next Diagnostic" },
      { "<leader>dK", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
      { "<leader>ra", vim.lsp.buf.code_action, desc = "Refactor: Code Action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>rf", format, desc = "Format Document", has = "documentFormatting" },
      { "<leader>rf", format, desc = "Format Range", mode = "v", has = "documentRangeFormatting" },
      { "<leader>rn", vim.lsp.buf.rename, desc = "Refactor: name", mode = "n", has = "rename" },
    }
  end
  return M._keys
end

function M.on_attach(client, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = {} ---@type table<string,LazyKeys|{has?:string}>

  for _, value in ipairs(M.get()) do
    local keys = Keys.parse(value)
    if keys[2] == vim.NIL or keys[2] == false then
      keymaps[keys.id] = nil
    else
      keymaps[keys.id] = keys
    end
  end

  for _, keys in pairs(keymaps) do
    if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
      local opts = Keys.opts(keys)
      ---@diagnostic disable-next-line: no-unknown
      opts.has = nil
      opts.silent = true
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
