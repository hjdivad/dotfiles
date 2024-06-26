---@type LazySpec[]
return {
  -- see <https://github.com/stevearc/oil.nvim>
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "-", "<CMD>Oil<CR>", { desc = "Open parent directory" } },
    },
    config = function()
      require("oil").setup({
        use_default_keymaps = false,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          -- ["<C-s>"] = "actions.select_vsplit",
          -- ["<C-h>"] = "actions.select_split",
          -- ["<C-t>"] = "actions.select_tab",
          ["P"] = "actions.preview",
          ["q"] = "actions.close",
          ["R"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["."] = "actions.cd",
          -- ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          -- ["g\\"] = "actions.toggle_trash",
        },
      })
    end,
  },
}
