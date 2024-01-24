---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/test/core.lua
    opts = {
      -- --- @type neotest.Config.summary
      -- summary = {},
      -- diagnostic config is not working
      -- ---@type neotest.Config.diagnostic
      -- diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
      ---@type neotest.Config.output
      output = { enabled = true, open_on_run = false }
    },
    keys = {
      { "<leader>tt", false },
      { "<leader>ts", false },
      { "<leader>tS", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
          require("neotest").summary.open()
        end,
        desc = "Run File"
      },
    }
    ,
  },
}
