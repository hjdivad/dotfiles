return {
  -- Disable this growl/toast distraction
  -- use show notifications; show-last notification instead
  {
    "rcarriga/nvim-notify",
    enabled = false,
    keys = {
      {
        "<leader>un", false
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },
}
