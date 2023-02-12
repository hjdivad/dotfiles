local Util = require("lazyvim.util")

return {
  -- see https://github.com/nvim-telescope/telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    keys = {
      -- disable LazyVim keymaps
      { "<leader>,", false },
      { "<leader> ", false },

      { "<leader>/", Util.telescope("live_grep"), desc = "Find in Files (Grep)" },
      { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Buffer" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags({})
        end,
        desc = "find (vim) help tags",
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            -- "unrestricted"; it conflicts with paging up though
            -- ["<c-u>"] = function()
            --   Util.telescope("find_files", { no_ignore = true, hidden = true })()
            -- end,
            ["<c-i>"] = function()
              Util.telescope("find_files", { no_ignore = true, prompt_title = "find files (no ignore)" })()
            end,
            ["<c-h>"] = function()
              Util.telescope("find_files", { hidden = true, prompt_title = "find files (hidden)" })()
            end,
            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart",
        },
      },
    },
  },
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
}
