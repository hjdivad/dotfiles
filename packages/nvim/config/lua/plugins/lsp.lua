local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

---@type LazyPluginSpec[]
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- lsp
        "lua-language-server",
        "marksman",
        "pyright",
        "ruff-lsp",
        "rust-analyzer",
        "sqlls",
        "typescript-language-server",
        "yaml-language-server",
        "json-lsp",

        -- dap
        "codelldb",
        "debugpy",

        -- linters
        "flake8",
        "shellcheck",
        "commitlint",

        -- formatters
        "fixjson",
        "markdownlint",
        "shfmt",
        "stylua",
      },
    },
  },
  {
    -- see https://www.lazyvim.org/plugins/lsp
    "neovim/nvim-lspconfig",
    -- override LSP keybindings here
    init = function()
      -- see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
      -- see $HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/keymaps.lua
      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      -- remove unwanted
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "gI", false }
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "<leader>cs", false }
      keys[#keys + 1] = { "<c-k>", false, mode = "i" }
      keys[#keys + 1] = { "<C-k>", false, mode = "i" }

      -- add missing
      keys[#keys + 1] = {
        "gt",
        function()
          require("telescope.builtin").lsp_type_definitions()
        end,
        desc = "Goto [T]ype Definition",
      }

      keys[#keys + 1] = {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        desc = "Goto Definition",
        has = "definition",
      }

      keys[#keys + 1] = {
        "gi",
        function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "Goto Implementation",
      }

      keys[#keys + 1] = { "<leader>cL", vim.diagnostic.open_float, desc = "Line Diagnostics" }
      keys[#keys + 1] = { "<leader>cj", diagnostic_goto(true, "ERROR"), desc = "Next Error Diagnostic" }
      keys[#keys + 1] = { "<leader>ck", diagnostic_goto(false, "ERROR"), desc = "Prev Error Diagnostic" }
      keys[#keys + 1] = { "<leader>cJ", diagnostic_goto(true), desc = "Next Diagnostic" }
      keys[#keys + 1] = { "<leader>cK", diagnostic_goto(false), desc = "Prev Diagnostic" }
      keys[#keys + 1] = { "<leader>cs", "<cmd>AerialToggle!<cr>", desc = "Code Symbols" }
      keys[#keys + 1] = { "<leader>cS", "<cmd>AerialOpen<cr>", desc = "Code Symbols (focus)" }
      keys[#keys + 1] =
        { "<c-h>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" }
    end,
    ---@type PluginLspOpts
    opts = {
      -- see https://www.lazyvim.org/plugins/lsp#nvim-lspconfig / Full Spec
      --
      -- LSP-specific keymaps here
      --
      -- servers = {
      --   lua_ls = {
      --     keys = {}
      --   }
      -- }
    },
  },
}
