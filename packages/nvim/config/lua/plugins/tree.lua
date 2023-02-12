return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      -- disable LazyVim keymaps
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>E", false },
      { "<leader>e", "<cmd>Neotree reveal_force_cwd<cr>", desc = "Open filesystem tree", remap = true },
      {
        "<leader>E",
        ":Neotree action=focus source=filesystem dir=",
        desc = "Open filesystem tree at <dir>",
        remap = true,
      },
    },
    opts = {
      window = {
        mappings = {
          ["<leader>/"] = function(state)
            -- TODO: debug; seems to have issues when loading file out of pwd
            local node = state.tree:get_node()
            require("telescope.builtin").live_grep({
              cwd = node.path,
              prompt_title = "rg (regex): " .. node.path,
            })
          end,
          -- open file & close neotree
          -- tree action=show source=filesystem dir=~/.
          ["o"] = function(state)
            local cmd = require("neo-tree/sources/filesystem/commands")
            cmd.open(state)
            vim.cmd([[Neotree close]])
          end,
        },
      },
    },
  },
}
