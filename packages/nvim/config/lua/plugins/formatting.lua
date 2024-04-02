---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opt = {
        formatters_by_ft = {
          markdown = { "prettier" },
          json = { "fixjson" },
          lua = { "stylua" },
          rust = { "rustfmt" },
          python = {},
        },
    },
  },
}
