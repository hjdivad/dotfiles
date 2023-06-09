---@type LazyPlutbl_dginSpec[]
local specs = {
  -- TODO: dapui better icons?
  -- TODO: dapui always open in new tab
  -- TODO: update osv and try to get lua plugin debugging working
  -- https://github.com/jbyuki/one-small-step-for-vimkind
  {
    -- https://github.com/rcarriga/nvim-dap-ui#configuration
    -- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/dap/core.lua
    -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
    -- https://microsoft.github.io/debug-adapter-protocol/overview
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- folke
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Repl" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },

      -- chrome
      -- nvim does not seem to be mapping <D-x> in my setup
      -- { "<D-M-b>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<M-b>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      -- { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      -- { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      -- { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
      -- { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      -- { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      -- { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      -- { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      -- { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      -- { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      -- { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      -- { "<leader>dr", function() require("dap").repl.open() end, desc = "Repl" },
      -- { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      -- { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      -- { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
      -- stylua: ignore
      keys = {
        -- folke
        -- { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
        -- { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
      },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },
    },
  },
}

return specs
