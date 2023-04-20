return {
  {
    -- TODO: try out https://github.com/rcarriga/cmp-dap maybe?
    --
    --
    -- TODO: setup launch configuration for e.g. data-eden
    -- probably need to bump vitest to latest
    -- see https://github.com/vitest-dev/vscode/issues/13
    -- see https://code.visualstudio.com/docs/editor/workspaces
    --  use vscode to get started with a launch.json
    -- TODO: launch vitest by launch configuration `require('dap').continue()`
      -- TODO: install json5
        -- TODO: :he dap-launch.json
    -- TODO: load by launch configuration
    --
    --  this way launch configurations can be checked into the repo as .vscode/launch.json
    -- TODO: configure https://github.com/theHamsta/nvim-dap-virtual-text
    -- TODO: configure breakpoint signs
    "mfussenegger/nvim-dap",
    -- TODO: :he dap-api
    config = function(_, opts)
      local dap = require("dap")
      dap.set_log_level('trace')
      dap.adapters.node2 = {
        type = "executable",
        command = "node-debug2-adapter",
      }
      -- TODO: configuration for typescript (vitest)
      -- TODO: configuration for debugging web
      dap.configurations.javascript = {
        {
          name = "Launch",
          type = "node2",
          request = "launch",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
        {
          -- For this to work you need to make sure the node process is started with the `--inspect` flag.
          name = "Attach to process",
          type = "node2",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }
    end,
  },
  {
    -- TODO: configure https://github.com/rcarriga/nvim-dap-ui#configuration
    -- `require('dap-ui').show() -- hide() toggle()`
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {},
  },
}
