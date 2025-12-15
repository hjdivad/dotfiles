---@type LazySpec[]
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opts = {

      log_level = vim.log.levels.INFO,
      default_format_opts = {
        lsp_format = "fallback",
        -- lsp_format = "never",
      },

      -- Expected to be paired with $REPOROOT/.lazy.lua
      --
      -- return {
      --   "stevearc/conform.nvim",
      --   opts = {
      --     formatters = {
      --       goimports = {
      --         args = { "--local", "github.com/my/cool/repo" },
      --       },
      --       golines = {
      --        args = { "--max-len", 100 }
      --       }
      --     },
      --     formatters_by_ft = {
      --       go = { "golines", "goimports", "gofmt" },
      --     },
      --   },
      -- }
      formatters = {
        -- Configure sqlfluff formatter to run from git root
        sqlfluff = {
          cwd = require("conform.util").root_file({ ".sqlfluff", ".git" }),
        },
      },
      formatters_by_ft = {
        typescript = { "prettier" },
        go = { "golines", "goimports", "gofmt" },
        toml = { "taplo" },
      },
    },
  },
}
