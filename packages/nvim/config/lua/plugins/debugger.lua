return {
  {
    -- TODO: try out https://github.com/rcarriga/cmp-dap
    -- TODO: install json5
    -- TODO: :he dap-launch.json
    --  this way launch configurations can be checked into the repo as .vscode/launch.json
    "mfussenegger/nvim-dap",
    config = function(_, opts)
      local dap = require("dap")
      dap.set_log_level('trace')
      dap.adapters.node2 = {
        type = "executable",
        command = "node-debug2-adapter",
      }
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
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {},
  },
}
