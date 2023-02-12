return {
  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xx", false },
      { "<leader>xX", false },
      { "<leader>xL", false },
      { "<leader>xQ", false },
      { "<leader>dd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>dD", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
    },
  },
}
