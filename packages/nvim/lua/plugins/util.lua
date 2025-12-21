---@type LazySpec
return {
  -- session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help" } },
    -- stylua: ignore
    keys = {
      { "<leader>qs", false }, -- restore session
      { "<leader>ql", false }, -- restore last session
      { "<leader>qd", false }, -- quit don't save
    },
  },
}
