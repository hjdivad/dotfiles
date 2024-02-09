---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/formatting
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@class ConformOpts
      local opts = {
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = {
          markdown = { "prettier" },
          json = { "fixjson" },
          lua = { "stylua" },
        },
      }
      return opts
    end,
  },
}
