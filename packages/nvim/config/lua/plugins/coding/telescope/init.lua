local Util = require("lazyvim.util")
local actions = require("telescope.actions")
local tmux = require("plugins/coding/telescope/tmux")

local function find_files_no_ignore()
  Util.telescope("find_files", { no_ignore = true, prompt_title = "find files (no ignore)" })()
end

local function find_files_hidden()
  Util.telescope("find_files", { hidden = true, prompt_title = "find files (hidden)" })()
end

local function find_files_attach(_, map)
  map("i", "<c-i>", find_files_no_ignore)
  map("i", "<c-h>", find_files_hidden)

  return true
end

---@type LazySpec[]
return {
  -- see https://github.com/nvim-telescope/telescope.nvim
  -- /Users/hjdivad/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/editor.lua
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim", "camgraff/telescope-tmux.nvim" },
    keys = {
      -- disable LazyVim keymaps
      { "<leader>,", false },
      { "<leader><space>", false },
      { "<leader>uC", false }, -- colorscheme selection
      { "<leader>gs", false }, -- git status

      { "<leader>/", Util.telescope("live_grep"), desc = "Find in Files (Grep)" },
      { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find line in Buffer" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").git_files({
            git_command = { "git", "diff", "--name-only", "--merge-base", "origin/HEAD" },
          })
        end,
        desc = "Find Git Changed Files (relative to origin/HEAD)",
      },
      { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Find git commits" },
      {
        "<leader>fg",
        Util.telescope("git_files", { attach_mappings = find_files_attach  }),
        desc = "Find Files (git)",
      },
      {
        "<leader>ff",
        Util.telescope("find_files", { attach_mappings = find_files_attach, cwd = vim.fn.getcwd() }),
        desc = "Find Files (cwd)",
      },
      {
        "<leader>fF",
        Util.telescope("find_files", { attach_mappings = find_files_attach, cwd=vim.uv.cwd(), hidden=true, no_ignore =true }),
        desc = "Find Files (+hidden +ignored)",
      },
      {
        "<leader>fj",
        Util.telescope("jumplist"),
        desc = "Find jumplist location",
      },
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
      -- TODO: this toggles sessions; do this in lua instead and toggle windows
      { "<leader>tst", "<Cmd>silent !tmux switch-client -l<cr>", desc = "tmux toggle" },
      {
        "<leader>tss",
        function()
          require("telescope").extensions.tmux.windows({
            -- Strip tmux format variables, although I would rather #{E:window_name} worked as expected
            entry_format = [=[#S: #{s/##\[[^]*]*\]//:window_name}]=],
            attach_mappings = tmux.attach_tmux_mappings,
          })
        end,
        desc = "tmux switch window",
      },
      {
        "<leader>tsn",
        function()
          tmux.new_tmux_session({})
        end,
        desc = "tmux new session",
      },
      {
        "<leader>tsd",
        function()
          tmux.goto_tmux_session("todos", "todos")
        end,
        desc = "tmux goto todos",
      },
      {
        "<leader>tsr",
        function()
          tmux.goto_tmux_session("todos", "reference")
        end,
        desc = "tmux goto reference",
      },
      {
        "<leader>tsj",
        function()
          tmux.goto_tmux_session("todos", "journal")
        end,
        desc = "tmux goto journal",
      },
    },
    opts = {
      defaults = {
        -- see https://www.lua.org/manual/5.1/manual.html#5.4.1
        -- these are lua regexes
        file_ignore_patterns = {
          -- even when looking for hidden and ignored files, disregard .git itself
          '^.git/',
          -- even when looking for ignored files, disregard cargo build targets
          '^target/',
          '/target/',
        },
        get_selection_window = function()
          local wins = vim.api.nvim_list_wins()
          table.insert(wins, 1, vim.api.nvim_get_current_win())
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buftype = vim.bo[buf].buftype
            if buftype == "" or buftype == "help" then
              return win
            end
          end
          return 0
        end,
        mappings = {
          i = {
            ["<C-n>"] = false, -- default mv next
            ["<C-p>"] = false, -- default mv prev
            ["<Down>"] = false, -- default down
            ["<Up>"] = false, -- default up
            ["<C-x>"] = false, -- default open horizontal
            ["<C-v>"] = false, -- default open veritcal
            ["<C-t>"] = false, -- default open tab
            ["<PageUp>"] = false, -- default scroll preview up
            ["<PageDown>"] = false, -- default scroll preview down
            ["<Tab>"] = false, -- default toggle selection + mv worse
            ["<S-Tab>"] = false, -- default toggle selection + mv bettter
            ["<C-q>"] = false, -- default send to qflist + open qflist
            ["<M-q>"] = false, -- default send selected to qflist + open qflist
            ["<C-w>"] = false, -- default ???

            ["<c-t>"] = false, -- lazyvim open with trouble
            ["<a-i>"] = false, -- lazyvim find files (no ignore)
            ["<a-h>"] = false, -- lazyvim find files (hidden)
            ["<C-Down>"] = false, -- lazyvim cycle history next
            ["<C-Up>"] = false, -- lazyvim cycle history prev
            ["<C-f>"] = false, -- lazyvim preview scroll down
            ["<C-b>"] = false, -- lazyvim preview scroll up

            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",

            ["<C-Space>"] = "toggle_selection",
            ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<m-l>"] = actions.send_to_qflist + actions.open_qflist,
          },
          n = {
            ["<C-x>"] = false, -- default open horizontal
            ["<C-v>"] = false, -- default open veritcal
            ["<C-t>"] = false, -- default open tab
            ["<Tab>"] = false, -- default toggle selection + mv worse
            ["<S-Tab>"] = false, -- default toggle selection + mv bettter
            ["<C-q>"] = false, -- default send to qflist + open qflist
            ["<M-q>"] = false, -- default send selected to qflist + open qflist
            ["<Down>"] = false, -- default down
            ["<Up>"] = false, -- default up
            ["<C-Down>"] = false, -- lazyvim cycle history next
            ["<C-Up>"] = false, -- lazyvim cycle history prev
            ["<PageUp>"] = false, -- default scroll preview up
            ["<PageDown>"] = false, -- default scroll preview down

            ["q"] = actions.close,

            ["<C-k>"] = "cycle_history_prev",
            ["<C-j>"] = "cycle_history_next",

            ["<Space>"] = "toggle_selection",
            ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<m-l>"] = actions.send_to_qflist + actions.open_qflist,
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
