---@type LazySpec
return {
  -- TODO: combine this with a good tmux-select and there might be a nice tmux session select here
  --  a. pick from local workspaces e.g. src/{gh,li} or dynamic search (gh; ghe)
  --  then tmux to the session and restore the vim session
  --
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
