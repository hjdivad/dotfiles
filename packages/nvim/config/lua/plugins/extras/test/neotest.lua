---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-plenary" },
    -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/test/core.lua
    opts = {
      -- --- @type neotest.Config.summary
      -- summary = {},
      -- diagnostic config is not working
      -- ---@type neotest.Config.diagnostic
      -- diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
      ---@type neotest.Config.output
      output = {
        enabled = true,
        open_on_run = false,
      },
      output_panel = {
        -- TODO: get this behaviour how i want it
        --  - only load the floating output, not the window at the bottom
        --  - autoload it on short test runs (the default actually)
        enabled = false,
        open_on_run = false,
      },
      ---@type neotest.Adapter[]
      adapters = {
        -- Can't just require it here because of load-order issues, but it's
        -- safe to call setup repeatedly so in a .nvim.lua
        --  require('neotest').setup({ adapters={ require('neotes-plenary')}})
        -- require("neotest-plenary"),
      },
    },
    keys = {
      { "<leader>tt", false },
      { "<leader>ts", false },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true, last_run = true })
        end,
        desc = "Show Output",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
          -- require("neotest").output.open({ enter = true, auto_close = true, last_run=true })
        end,
        desc = "Run Last",
      },
      {
        "<leader>tS",
        function()
          require("neotest").summary.toggle()
          vim.defer_fn(function()
            -- Type annotations are wrong for bufwinid
            ---@diagnostic disable-next-line: param-type-mismatch
            local win = vim.fn.bufwinid("Neotest Summary")
            -- see https://github.com/nvim-neotest/neotest/issues/275
            -- see https://github.com/nvim-neotest/neotest/discussions/197#discussioncomment-4775271
            if win > -1 then
              vim.api.nvim_set_current_win(win)
            end
          end, 101)
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
          require("neotest").summary.open()
        end,
        desc = "Run File",
      },
    },
  },
}
