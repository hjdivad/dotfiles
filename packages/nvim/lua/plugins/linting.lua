---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/linting
  -- see :help nvim-lint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      local fluff = require('lint').linters.sqlfluff
      fluff.args = { "lint", "--format=json" }
      return opts
    end,
  },
}
