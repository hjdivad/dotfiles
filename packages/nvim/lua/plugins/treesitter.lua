---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/treesitter
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    enabled = true,
    opts = { mode = "cursor", max_lines = 3 },
    config = function (_, opts)
      require('nvim-treesitter.configs').setup(opts)
      local overrides = require('hjdivad_util.ts_overrides')
      overrides.load_ts_query_overrides()
    end,
    keys = {
      {
        "<leader>ut",
        false,
      },
    },
  },
}
