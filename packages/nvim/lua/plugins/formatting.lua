---@type LazySpec[]
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opts = {

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
      formatters_by_ft = {
        typescript = { "prettier" },
        go = { "golines", "goimports", "gofmt" },
        toml = { "taplo" },
      },
    },
  },
}
