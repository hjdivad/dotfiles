local LualineCodeCompanionSpinner = require("lualine.component"):extend()
local spinner_symbols = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}

function LualineCodeCompanionSpinner:init(options)
  LualineCodeCompanionSpinner.super.init(self, options)
  self.spinner_index = 1

  local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        self.processing = true
      elseif request.match == "CodeCompanionRequestFinished" then
        self.processing = false
      end
    end,
  })
end

-- Function that runs every time statusline is updated
function LualineCodeCompanionSpinner:update_status()
  if self.processing then
    self.spinner_index = (self.spinner_index % #spinner_symbols) + 1
    return [[󰚩  ]] .. spinner_symbols[self.spinner_index]
  else
    return nil
  end
end

---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd" },

    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>af",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "Prompt Actions (CodeCompanion)",
      },
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle (CodeCompanion)" },
      { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add code to CodeCompanion" },
    },

    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = { api_key = "AI_CLAUDE_CODE_COMPANION_KEY" },
          })
        end,

        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = { api_key = "AI_OPENAI_CODE_COMPANION_KEY" },
          })
        end,

        copilot = {
          model = "claude-3.5-sonnet",
        },
      },

      strategies = {
        chat = {
          adapter = "anthropic",
          -- keymaps = {},
        },
        inline = { adapter = "anthropic" },
        agent = { adapter = "anthropic" },
      },

      -- see <https://codecompanion.olimorris.dev/configuration/chat-buffer.html#layout>
      display = {
        chat = {
          window = {
            position = "right",
          },
        },
      },
      slash_commands = {
        ["buffer"] = {
          opts = {
            provider = "snacks",
          },
        },
        ["help"] = {
          opts = {
            provider = "snacks",
            max_lines = 1000,
          },
        },
        ["file"] = {
          opts = {
            provider = "snacks",
          },
        },
        ["symbols"] = {
          opts = {
            provider = "snacks",
          },
        },
        ["workspace"] = {
          opts = {
            provider = "snacks",
          },
        },
      },

      -- see <https://codecompanion.olimorris.dev/configuration/action-palette.html>
      -- action_palette = {
      --   opts = {
      --     show_default_actions = false,
      --     show_default_prompt_library = false,
      --   }
      -- }

      -- logs in $HOME/.local/state/nvim/codecompanion.log
      -- log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    -- opts = {
    --   sections = {
    --     lualine_y = {
    --       { LualineCodeCompanionSpinner },
    --       { "progress", separator = " ", padding = { left = 1, right = 0 } },
    --       { "location", padding = { left = 0, right = 1 } },
    --     },
    --   },
    -- },
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_y = vim.list_extend(opts.sections.lualine_y or {}, {
        { LualineCodeCompanionSpinner },
      })
      return opts
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },

  -- TODO: workaround for a codecompanion + blink bug
  -- see <https://github.com/olimorris/codecompanion.nvim/issues/968#issuecomment-2672905893>
  -- see <https://github.com/Saghen/blink.cmp/issues/1303>
  {
    "saghen/blink.cmp",
    optional = true,
    tag = "v0.12.2",
    opts = function(_, opts)
      opts.completion.accept.dot_repeat = false
    end,
  },
}
