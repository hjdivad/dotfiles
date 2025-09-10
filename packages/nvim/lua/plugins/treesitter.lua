---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/treesitter
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "LazyFile",
    opts = { enable = true, mode = "cursor", max_lines = 3 },
    config = function(_, opts)
      local overrides = require("hjdivad.ts_overrides")
      overrides.load_ts_query_overrides()
      require("treesitter-context").setup(opts)
    end,
    keys = {
      {
        "<leader>ut",
        false,
      },
    },
  },
}
