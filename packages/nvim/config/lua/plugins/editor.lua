---@type LazyPluginSpec[]
return {
  -- see https://www.lazyvim.org/plugins/editor

  -- diagnostics
  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xx", false },
      { "<leader>xX", false },
      { "<leader>xL", false },
      { "<leader>xQ", false },
      { "<leader>cq", "<cmd>Trouble diagnostics close<cr>", desc = "Close Diagnostics (Trouble)" },
      { "<leader>cd", "<cmd>Trouble diagnostics filter.buf=0 focus=true<cr>", desc = "Document Diagnostics (Trouble)" },
      -- TODO: can we filter these by path?
      { "<leader>cD", "<cmd>Trouble diagnostics focus=true<cr>", desc = "Workspace Diagnostics (Trouble)" },
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
          ["a"] = {
            "add",
            config = {
              show_path = "relative",
            },
          },
          ["m"] = {
            "move",
            config = {
              show_path = "relative",
            },
          },
          ["<leader>/"] = function(state)
            local node = state.tree:get_node()
            local gf = require("grug-far")
            local saved_splitright = vim.opt.splitright

            vim.opt.splitright = true
            gf.grug_far({ prefills = { paths = node.path } })
            vim.opt.splitright = saved_splitright
          end,
          -- open file & close neotree
          -- tree action=show source=filesystem dir=~/.
          ["o"] = function(state)
            local cmd = require("neo-tree/sources/filesystem/commands")
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/aec592bb1f0cf67f7e1123053d1eb17700aa9ed4/lua/neo-tree/sources/common/commands.lua#L541-L594
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/aec592bb1f0cf67f7e1123053d1eb17700aa9ed4/lua/neo-tree/utils.lua#L416-L460
            cmd.open(state)
            vim.cmd([[Neotree close]])
          end,
        },
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      { "<leader>/", "<cmd>GrugFar<cr>", desc = "Search with GrugFar" },
    },
  },
  {
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          enabled = false,
        },
      },
    },
  },

  -- todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", false},
      { "<leader>xT", false},
    },
    --TODO: opts.search use git diff $(git merge-base origin/master) rather than rg
    --see <https://github.com/folke/todo-comments.nvim#%EF%B8%8F-configuration>
  },

  -- find & replace
  {
    "nvim-pack/nvim-spectre",
    -- stylua: ignore
    keys = {
      {'<leader>sr', false},
      { "<leader>fr", function() require("spectre").open() end, desc = "Find [and replace] in files (Spectre)" },
    },
  },

  -- git
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      base = "origin/HEAD",
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        local function preview_hunk()
          -- call twice to focus on the previe window
          gs.preview_hunk()
          gs.preview_hunk()
        end

        local function update_git_base()
          local merge_base = vim.fn.system("git merge-base HEAD origin/HEAD")
          if merge_base and #merge_base > 3 then
            -- strip newline from the command output
            gs.change_base(merge_base:sub(1, #merge_base - 1), true)
          end
        end

        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map("n", "<leader>gj", gs.next_hunk, "Goto Next Hunk")
        map("n", "<leader>gk", gs.prev_hunk, "Goto Prev Hunk")
        map("n", "<leader>gp", preview_hunk, "Goto Preview Hunk")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>Gd", gs.diffthis, "Diff This")
        map("n", "<leader>GB", update_git_base, "Set git base to --merge-base")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "G" },
    keys = {
      {
        "<leader>yg",
        ":GBrowse!<Cr>",
        mode = "v",
        silent = true,
        desc = "Yank GitHub permalink to clipboard",
      },
      {
        "<leader>GD",
        "<Cmd>Gvdiffsplit!<Cr>",
        mode = "n",
        desc = "Diff this conflict",
      },
    },
  },
}
