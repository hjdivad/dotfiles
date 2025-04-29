---@type LazySpec[]
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
      },
    },
  },
}
