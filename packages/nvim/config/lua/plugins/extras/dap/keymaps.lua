---@type LazySpec
return {
  -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/dap/core.lua
  -- see https://microsoft.github.io/debug-adapter-protocol/specification#Events
  -- see https://microsoft.github.io/debug-adapter-protocol/specification#Requests
  --
  -- TODO: review he: dap.txt
  -- TODO: review dapui nvim-dap-ui.txt
  --
  -- TODO: how/can?
  --  rust memory breakpoint
  --    write to x
  --    x == y
  --    x != y
  --    read from x
  --  rust exception breakpoint?
  --    - i.e. on error?
  --  rust reverse debugging?
  --  in which case recall require('dap').set_exception_breakpoints()
  --
  -- TODO: runDebuggables (rust) ; similar in lua?
  -- TODO: more keymaps
  --    step in
  --    setp out
  --    step over
  --    step back
  --    restart frame
  --    step continue reverse
  --    continue to cursor
  --    toggle breakpoint
  --    toggle breakpoint condition
  --    toggle logpoint (breakpoint(nil,nil,log))
  --    stack down
  --    stack up
  --    stack up to top
  --    go to stack
  --    go to repl (dap.repl.open())
  --    eval under cursor
  --    eval input
  --    - input from user vim.fn.input(prompt)
  --    - eval expr, {enter=true}
  --    - there's also require('dap.ui.widgets').hover() + preview()
  --    dapui reset windows (e.g. if someone else messed them up)
  --
  -- TODO: configure dapui
  --  don't autoclose
  --  wider left panels
  --
  -- TODO: configure codelldb
  --  - breakpoint command adding doesn't work; not prompted for input
  --    - prevents e.g. logpoints
  --
  -- TODO: support lua
  --  works:
  --    ```
  --      require('osv').launch({ port=8086}) -- in A
  --      <leader>dc -- select "attach" -- in B
  --      -- trigger breakpoint in A multiple times
  --    ```
  --  doesn't work
  --    * connect, disconnect, reconnect from debugger
  --    * `require('osv').stop()`, i.e. restarting in debuggee (short of sudokuing nvim process)
  --      * `require('osv').is_running() == false` but port is still open
  --
  --
  -- require('dap').listeners.after.event_initialized['hjdivad-keymaps'] = function() end
  -- require('dap').listeners.after.event_terminated['hjdivad-keymaps'] = function() end

  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "<leader>de", function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval", mode = { "n", "v" } },
      {
        "<leader>dE",
        function()
          require("dapui").eval(vim.fn.input({ prompt = "> ", cancelreturn = nil }),
            { enter = true })
        end,
        desc = "Eval",
        mode = { "n", "v" }
      },
    },
    opts = {
      ---@type dapui.Config.layout[]
      layouts = {
        {
          elements = { {
            id = "scopes",
            size = 0.25
          }, {
            id = "breakpoints",
            size = 0.25
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.25
          } },
          position = "left",
          size = 80
        }, {
        elements = { {
          id = "repl",
          size = 0.5
        }, {
          id = "console",
          size = 0.5
        } },
        position = "bottom",
        size = 10
      }
      }
    }
  }
}
