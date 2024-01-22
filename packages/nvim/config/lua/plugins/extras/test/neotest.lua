---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/test/core.lua
    keys = {
      { "<leader>tt", false },
      { "<leader>ts", false },
      { "<leader>tO", false },
      { "<leader>to", function() require("neotest").output_panel.toggle({enter=true}) end, desc = "Toggle Output Panel" },
      { "<leader>tf", function()
        require("neotest").run.run(vim.fn.expand("%"))
        require("neotest").summary.open()
      end, desc = "Run File" },
    }
    ,
  },
}
