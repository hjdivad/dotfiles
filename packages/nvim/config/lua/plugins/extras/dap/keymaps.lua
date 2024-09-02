local hjdivad_util = require('hjdivad_util')
local hjdivad_os = require("hjdivad_util.os")
local ft_keymaps = vim.api.nvim_create_augroup("nvim_dap_keymaps", { clear = true })

local args_list = hjdivad_util.args_list
local ConfigurationsPath = hjdivad_os.cache_path("dap-configurations.json")

local function load_configurations()
  local config_file = io.open(ConfigurationsPath, 'r')
  if config_file then
    local config_json_str = config_file:read('*a')
    return vim.json.decode(config_json_str)
  else
    return {}
  end
end

---@param config DapConfiguration
local function save_configuration(config)
  local configs = load_configurations()
  configs[#configs+1] = config

  local config_json = vim.json.encode(configs)

  os.execute('mkdir -p $(dirname ' .. ConfigurationsPath .. ')')
  local config_file = assert(io.open(ConfigurationsPath, 'w'))
  config_file:write(config_json)
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "python",
  group = ft_keymaps,
  callback = function()
    vim.keymap.set("n", "<leader>dr", function()
      local n = require("noice")
      local venv = require("hjdivad_util/venv")
      local dap = require("dap")

      local function echo(msg)
        n.redirect(function()
          print(msg)
        end)
      end

      local configs = venv.dap_configurations()
      local configs_count = #configs

      if configs_count == 0 then
        echo("No Python debuggables found.")
        return
      end

      local config_actions = {
        {
          name = " add runnable",
          act = function()
            vim.ui.input({
              prompt = "Enter program + args",
            }, function(value)
              if value ~= nil then
                local words = args_list(value)
                if #words > 0 then
                  local cmd = words[1]
                  local args = {}
                  for i = 2, #words do
                    args[#args + 1] = words[i]
                  end

                  local config = venv.dap_configuration(cmd, args)
                  save_configuration(config)
                end
              end
            end)
          end,
        },
      }

      local runnable_variant_actions = vim.tbl_map(function(upstream_config)
        return {
          name = " add runnable w/args (conways)",
          act = function()
            vim.ui.input({
              prompt = "Enter variant alias + args",
            }, function(value)
              if value ~= nil then
                local words = args_list(value)
                if #words > 0 then
                  local variant_name = words[1]
                  local args = {}
                  for i = 2, #words do
                    args[#args + 1] = words[i]
                  end

                  local name = upstream_config.name .. ' (' .. variant_name .. ')'
                  local config = venv.dap_configuration(name, upstream_config.program, args)
                  save_configuration(config)
                end
              end
            end)
          end,
        }
      end, configs)
      config_actions = vim.list_extend(config_actions, runnable_variant_actions)
      if #config_actions > 1 then
        config_actions = vim.list_extend(config_actions, {
          {
            name = "󰆴 delete custom runnables",
            act = function()
              os.remove(ConfigurationsPath)
            end,
          },
        })
      end

      local choices = vim.list_extend({}, configs)
      local saved_configs = load_configurations()
      if saved_configs then
        choices = vim.list_extend(choices, saved_configs)
        configs = vim.list_extend(configs, saved_configs)
        configs_count = configs_count + #saved_configs
      end
      choices = vim.list_extend(choices, config_actions)

      local choice_names = vim.tbl_map(function(config)
        return config.name
      end, choices)
      vim.ui.select(choice_names, {
        prompt = "Python Debuggables",
      }, function(choice, idx)
        if choice == nil then
          return
        end

        if idx <= configs_count then
          local config = configs[idx]
          dap.run(config)
        else
          choices[idx].act()
        end
      end)
    end, { buffer = true })
  end,
})

---@type LazySpec
return {
  -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/dap/core.lua
  -- see https://microsoft.github.io/debug-adapter-protocol/specification#Events
  -- see https://microsoft.github.io/debug-adapter-protocol/specification#Requests

  -- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/dap/core.lua
  {

    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "jonstoler/lua-toml",
        build = function(plugin)
          local dir = plugin.dir
          os.execute([[mkdir -p "]] .. dir .. [[/lua"]])
          os.execute([[ln -s "]] .. dir .. [[/toml.lua" "]] .. dir .. [[/lua/toml.lua"]])
        end,
      },
      {
        "linux-cultist/venv-selector.nvim",
      },
    },
    keys = {
      -- these all have better mappings below
      { "<leader>dg", false },
      { "<leader>di", false },
      { "<leader>dj", false },
      { "<leader>dk", false },
      { "<leader>do", false },
      { "<leader>dO", false },
      { "<leader>dw", false },
      { "<leader>dr", false },
      {
        "<leader>de",
        function()
          -- TODO: this enters correctly from command prompt but not from keymap
          -- TODO: try to next-tick it?
          require("dapui").eval(nil, { enter = true })
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
      {
        "<leader>dE",
        function()
          require("dapui").eval(vim.fn.input({ prompt = "> ", cancelreturn = nil }), { enter = true })
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      -- auto open, but don't auto close
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.after.event_initialized["dapui_keymaps"] = function()
        ---@type MapStack
        local map_stack = require("hjdivad_util/map_stack")
        map_stack.push(function(keymap)
          -- dap thinks stacks grow down
          keymap.set("n", "<c-j>", dap.up, { desc = "down one stack frame" })
          keymap.set("n", "<c-k>", dap.down, { desc = "up one stack frame" })

          -- ❤️ but generally unsupported by adapters
          -- dap.step_back
          -- dap.reverse_continue
          -- dap.restart_frame
          keymap.set("n", "<M-;>", dap.step_into, { desc = "(chrome) step into fn" })
          keymap.set("n", "<M-'>", dap.step_over, { desc = "(chrome) step over fn" })
          -- wezterm.lua maps ⌘⇧-; to <f26>
          keymap.set("n", "<F26>", dap.step_out, { desc = "(chrome) step out" })

          -- TODO: test these
          keymap.set("n", "<M-J>", dap.step_into, { desc = "(dap) step into fn" })
          keymap.set("n", "<M-j>", dap.step_over, { desc = "(dap) step over fn" })
          keymap.set("n", "<M-k>", dap.step_out, { desc = "(dap) step out" })

          -- dap.continue           <leader>dc
          -- dap.run_to_cursor      <leader>dC
          -- dap.toggle_breakpoint  <leader>db
          -- breakpoint condition   <leader>dB
          keymap.set("n", "<leader>dL", function()
            return dap.toggle_breakpoint(nil, nil, vim.fn.input({ prompt = "> ", cancelreturn = nil }), nil)
          end, { desc = "logpoint" })

          -- wezterm.lua maps <c-`> to <F25>
          keymap.set("n", "<F25>", function()
            dapui.float_element("repl", { width = 200, height = 200, enter = true, title = "REPL" })
          end, { desc = "(chrome) repl" })
          keymap.set("n", "<leader>dR", function()
            dapui.float_element("repl", { width = 200, height = 200, enter = true, title = "REPL" })
          end, { desc = "repl" })

          -- these might be backwards?
          keymap.set("n", "<c-,>", dap.up, { desc = "(chrome) down one stack frame" })
          keymap.set("n", "<c-.>", dap.down, { desc = "(chrome) up one stack frame" })
        end)
      end
      dap.listeners.before.event_terminated["dapui_keymaps"] = function()
        ---@type MapStack
        local map_stack = require("hjdivad_util/map_stack")
        map_stack.pop()
      end
    end,
    opts = {
      ---@type dapui.Config.layout[]
      layouts = {
        -- this is a list of layouts that can individiually be open/close/toggled
        {
          elements = { {
            id = "console",
            size = 1.0,
          } },
          position = "bottom",
          size = 10,
        },
        {
          elements = {
            {
              id = "scopes",
              size = 0.3,
            },
            {
              id = "breakpoints",
              size = 0.3,
            },
            {
              id = "stacks",
              size = 0.3,
            },
            {
              id = "watches",
              size = 0.1,
            },
          },
          position = "left",
          size = 80,
        },
      },
    },
  },
}
