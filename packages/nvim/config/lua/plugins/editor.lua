---@type LazySpec
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
      { "<leader>cq", "<cmd>TroubleClose<cr>", desc = "Close Diagnostics (Trouble)" },
      { "<leader>cd", "<cmd>Trouble document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>cD", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
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
      --TODO: i'd love to have a variant of this that only matched lines that were in the git diff
      --from e.g. ``git diff -U0 | rg '(?<=^\+(?!\+))(.*)' --pcre2 -o`
      --This is likely doable via rg's --pre and --glob args
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find todos" },
    },
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
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "契" },
        topdelete = { text = "契" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
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
