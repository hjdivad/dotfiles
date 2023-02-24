local Util = require("lazyvim.util")
local actions = require('telescope.actions')

local function find_files_no_ignore()
  Util.telescope("find_files", { no_ignore = true, prompt_title = "find files (no ignore)" })()
end

local function find_files_hidden()
  Util.telescope("find_files", { hidden = true, prompt_title = "find files (hidden)" })()
end

local function close_telescope()
  return require("telescope.actions").close()
end


local function find_files_attach(_, map)
  map('i', '<c-i>', find_files_no_ignore)
  map('i', '<c-h>', find_files_hidden)

  return true
end 

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
      { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find line in Buffer" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").git_files({
            git_command = { "git", "diff", "--name-only", "origin/HEAD" },
          })
        end,
        desc = "Find Git Changed Files (relative to origin/HEAD)",
      },
      { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Find git commits" },
      { "<leader>ff", Util.telescope("files", { attach_mappings = find_files_attach}), desc = "Find Files (root dir)" },
      { "<leader>fF", Util.telescope("files", { cwd = false , attach_mappings = find_files_attach}), desc = "Find Files (cwd)" },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags({})
        end,
        desc = "find (vim) help tags",
      },
      {
        "<leader>ss",
        Util.telescope("lsp_document_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
          },
        }),
        desc = "Search Symbol",
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-n>"] = false,        -- default mv next
            ["<C-p>"] = false,        -- default mv prev
            ["<Down>"] = false,       -- default down
            ["<Up>"] = false,         -- default up
            ["<C-x>"] = false,        -- default open horizontal
            ["<C-v>"] = false,        -- default open veritcal
            ["<C-t>"] = false,        -- default open tab
            ["<PageUp>"] = false,     -- default scroll preview up
            ["<PageDown>"] = false,   -- default scroll preview down
            ["<Tab>"] = false,        -- default toggle selection + mv worse
            ["<S-Tab>"] = false,      -- default toggle selection + mv bettter
            ["<C-q>"] = false,        -- default send to qflist + open qflist
            ["<M-q>"] = false,        -- default send selected to qflist + open qflist
            ["<C-w>"] = false,        -- default ???

            ["<c-t>"] = false,        -- lazyvim open with trouble
            ["<a-i>"] = false,        -- lazyvim find files (no ignore)
            ["<a-h>"] = false,        -- lazyvim find files (hidden)
            ["<C-Down>"] = false,     -- lazyvim cycle history next
            ["<C-Up>"] = false,       -- lazyvim cycle history prev
            ["<C-f>"] = false,        -- lazyvim preview scroll down
            ["<C-b>"] = false,        -- lazyvim preview scroll up

            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",

            ["<C-Space>"] = "toggle_selection",
            ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<m-l>"] = actions.send_to_qflist + actions.open_qflist,
          },
          n = {
            ["<C-x>"] = false,        -- default open horizontal
            ["<C-v>"] = false,        -- default open veritcal
            ["<C-t>"] = false,        -- default open tab
            ["<Tab>"] = false,        -- default toggle selection + mv worse
            ["<S-Tab>"] = false,      -- default toggle selection + mv bettter
            ["<C-q>"] = false,        -- default send to qflist + open qflist
            ["<M-q>"] = false,        -- default send selected to qflist + open qflist
            ["<Down>"] = false,       -- default down
            ["<Up>"] = false,         -- default up
            ["<C-Down>"] = false,     -- lazyvim cycle history next
            ["<C-Up>"] = false,       -- lazyvim cycle history prev
            ["<PageUp>"] = false,     -- default scroll preview up
            ["<PageDown>"] = false,   -- default scroll preview down

            ["q"] = close_telescope,

            ["<C-k>"] = "cycle_history_prev",
            ["<C-j>"] = "cycle_history_next",

            ["<Space>"] = "toggle_selection",
            ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<m-l>"] = actions.send_to_qflist + actions.open_qflist,
          }
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