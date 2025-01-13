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
        "shfmt",
        "stylua",
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
          ['rust-analyzer'] = {
            diagnostics = {
              -- see <https://rust-analyzer.github.io/manual.html#diagnostics>
              disabled = { "proc-macro-disabled" }
            }
          }
        }
      }

    }
  },
  {
    -- see https://www.lazyvim.org/plugins/lsp
    "neovim/nvim-lspconfig",
    -- override LSP keybindings here
    init = function()
      -- see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
      -- see $HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/keymaps.lua
      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      -- FIXME: these are no longer being removed
      --
      -- remove unwanted
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "gI", false }
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "<leader>cs", false }
      keys[#keys + 1] = { "<c-k>", false, mode = "i" }
      keys[#keys + 1] = { "<C-k>", false, mode = "i" }

      -- see :he fzf-lua-lsp/diagnostics
      -- add missing
      keys[#keys + 1] = {
        "gt",
        '<cmd>FzfLua lsp_typedefs<cr>',
        desc = "Goto [T]ype Definition",
      }

      keys[#keys + 1] = {
        "gd",
        '<cmd>FzfLua lsp_definitions<cr>',
        desc = "Goto Definition",
        has = "definition",
      }

      keys[#keys + 1] = {
        "gi",
        '<cmd>FzfLua lsp_implementations<cr>',
        desc = "Goto Implementation",
      }

      keys[#keys + 1] = { "<leader>cL", vim.diagnostic.open_float, desc = "Line Diagnostics" }
      keys[#keys + 1] = { "<leader>cj", diagnostic_goto(true, "ERROR"), desc = "Next Error Diagnostic" }
      keys[#keys + 1] = { "<leader>ck", diagnostic_goto(false, "ERROR"), desc = "Prev Error Diagnostic" }
      keys[#keys + 1] = { "<leader>cJ", diagnostic_goto(true), desc = "Next Diagnostic" }
      keys[#keys + 1] = { "<leader>cK", diagnostic_goto(false), desc = "Prev Diagnostic" }
      keys[#keys + 1] =
        { "<c-h>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" }
    end,
    ---@type PluginLspOpts
    opts = {
      -- see https://www.lazyvim.org/plugins/lsp#nvim-lspconfig / Full Spec
      --
      -- LSP-specific keymaps here
      --
      ---@type lspconfig.options
      ---@diagnostic disable-next-line: missing-fields
      servers = {
        ---@diagnostic disable-next-line: missing-fields
        lua_ls = {
          --TODO: mv this to  packages/nvim/config/lua/plugins/extras/dap/keymaps.lua
          --in lua autocmd
          keys = {
            {
              "<leader>dr",
              function()
                local osv = require("osv")
                if osv.is_running() then
                  osv.stop()
                  print("server stopped")
                else
                  osv.launch({ port = 8086 })
                end
              end,
              desc = "Toggle OSV (lua debugee server)",
            },
          },
        },
      },
    },
  },
}
