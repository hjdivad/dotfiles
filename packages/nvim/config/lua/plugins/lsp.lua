local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  -- override LSP keybindings here
  init = function()
    -- see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
    local keys = require("lazyvim.plugins.lsp.keymaps").get()

    -- remove unwanted
    keys[#keys + 1] = { "gy", false }
    keys[#keys + 1] = { "gI", false }

    -- add missing
    keys[#keys + 1] = {
      "gt",
      function()
        require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
      end,
      desc = "Goto [T]ype Definition",
    }

    keys[#keys + 1] = {
      "gi",
      function()
        require("telescope.builtin").lsp_implementations({ reuse_win = true })
      end,
      desc = "Goto Implementation",
    }

    keys[#keys + 1] = { "<leader>cL", vim.diagnostic.open_float, desc = "Line Diagnostics" }
    keys[#keys + 1] = { "<leader>cj", diagnostic_goto(true, "ERROR"), desc = "Next Error Diagnostic" }
    keys[#keys + 1] = { "<leader>ck", diagnostic_goto(false, "ERROR"), desc = "Prev Error Diagnostic" }
    keys[#keys + 1] = { "<leader>cJ", diagnostic_goto(true), desc = "Next Diagnostic" }
    keys[#keys + 1] = { "<leader>cK", diagnostic_goto(false), desc = "Prev Diagnostic" }
  end,
}
