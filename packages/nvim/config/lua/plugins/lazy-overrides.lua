local Util = require("lazyvim.util")

-- TODO: snippets + completion
-- see https://github.com/folke/lazy.nvim#-plugin-spec
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      -- TODO: do i want this?
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  -- stylua: ignore
  keys = {
    {
        --TODO: fix this
      "<tab>",
      function()
        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
      end,
      expr = true, silent = true, mode = "i",
    },
    { "<c-j>", function() require("luasnip").jump(1) end, mode = "s" },
    { "<c-k>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      -- disable LazyVim keymaps
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>E", false },
      { "<leader>e", "<cmd>Neotree reveal_force_cwd<cr>", desc = "Open filesystem tree", remap = true },
    },
    opts = {
      window = {
        mappings = {
          -- open file & close neotree
          ["o"] = function(state)
            local cmd = require("neo-tree/sources/filesystem/commands")
            cmd.open(state)
            vim.cmd([[Neotree close]])
          end,
        },
      },
    },
  },

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
              Util.telescope("find_files", { no_ignore = true })()
            end,
            ["<c-h>"] = function()
              Util.telescope("find_files", { hidden = true })()
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
