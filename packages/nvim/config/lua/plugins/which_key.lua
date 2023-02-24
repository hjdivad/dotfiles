return {
  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register({
        mode = { "n", "v" },
        ["g"] = { name = "+goto (builtin)" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>r"] = { name = "+refactor" },
        ["<leader>f"] = { name = "+find" },
        ["<leader>g"] = { name = "+goto" },
        ["<leader>G"] = { name = "+git/hunks" },
        ["<leader>s"] = { name = "+search/show" },
        ["<leader>n"] = { name = "+notifications" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>un"] = { name = "+notifications" },
      })
    end,
  },
}
