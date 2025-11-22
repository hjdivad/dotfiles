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
    "mason-org/mason.nvim",
    dependencies = { "Zeioth/mason-extra-cmds", opts = {} },
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
      "MasonUpdateAll", -- this cmd is provided by mason-extra-cmds
    },
    opts = {
      ensure_installed = {
        -- lsp
        "bash-language-server",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "pyright",
        "ruff",
        "sqlls",
        "taplo",
        "typescript-language-server",
        "yaml-language-server",

        -- dap
        "codelldb",
        "debugpy",

        -- linters
        "flake8",
        "shellcheck",
        "commitlint",

        -- formatters
        "fixjson",
        "shfmt",
        "stylua",
        "gofumpt",
        "gopls",
        -- goimports requires per-project configuration in .lazy.lua
        -- return {
        --  {
        --  	"stevearc/conform.nvim",
        --  	opts = {
        --  		formatters = {
        --  			goimports = {
        --  				args = { "--local", "github.com/my/local/package" },
        --  			},
        --  		},
        --  	},
        --  },
        -- }
        "goimports",
      },
      setup = {
        -- skip mason setup; rely on rust_analyzer from rustacean (which uses rustup)
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    -- These opts get merged into vim.g.rustaceanvim
    -- in ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/lang/rust.lua
    opts = {
      ---@type rustaceanvim.lsp.ClientOpts
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              -- see <https://rust-analyzer.github.io/manual.html#diagnostics>
              disabled = { "proc-macro-disabled" },
            },
          },
        },
      },
    },
  },

  {
    -- see https://www.lazyvim.org/plugins/lsp
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      -- see https://www.lazyvim.org/plugins/lsp#nvim-lspconfig / Full Spec
      --
      -- LSP-specific keymaps here
      --
      ---@type lspconfig.options
      ---@diagnostic disable-next-line: missing-fields
      servers = {
        ["*"] = {
          keys = {
            { "gy", false },
            { "gI", false },
            { "gd", false },
            { "<leader>cs", false },
            { "<c-k", false, mode = "i" },
            { "<c-K", false, mode = "i" },

            { "gt", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Goto [T]ype Definition" },
            { "gd", "<cmd>FzfLua lsp_definitions<cr>", desc = "Goto Definition", has = "definition" },
            { "gi", "<cmd>FzfLua lsp_implementations<cr>", desc = "Goto Implementation" },

            { "<leader>cL", vim.diagnostic.open_float, desc = "Line Diagnostics" },
            { "<leader>cj", diagnostic_goto(true, "ERROR"), desc = "Next Error Diagnostic" },
            { "<leader>ck", diagnostic_goto(false, "ERROR"), desc = "Prev Error Diagnostic" },
            { "<leader>cJ", diagnostic_goto(true), desc = "Next Diagnostic" },
            { "<leader>cK", diagnostic_goto(false), desc = "Prev Diagnostic" },
            { "<c-h>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
          },
        },
        ---@diagnostic disable-next-line: missing-fields
        lua_ls = {
          --TODO: mv this to  packages/nvim/lua/plugins/extras/dap/keymaps.lua
          --in lua autocmd
          keys = {
            {
              "<leader>dr",
              function()
                local osv = require("osv")
                if osv.is_running() then
                  osv.stop()
                  vim.print("server stopped")
                else
                  osv.launch({ port = 8086 })
                end
              end,
              desc = "Toggle OSV (lua debugee server)",
            },
          },
        },
        taplo = {},
      },
    },
  },
  { "Zeioth/mason-extra-cmds", version = "^1.0.0" },
}
