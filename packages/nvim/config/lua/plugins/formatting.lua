---@type LazySpec[]
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { { "prettierd", "prettier" } },
        json = { "fixjson" },
        lua = { "stylua" },
        rust = { "rustfmt" },
        python = {},
      },
    },
  },
}
