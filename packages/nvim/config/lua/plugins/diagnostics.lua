return {
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
}
