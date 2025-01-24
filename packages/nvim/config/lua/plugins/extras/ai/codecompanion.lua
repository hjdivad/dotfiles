---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd" },

    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>aA",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "Prompt Actions (CodeCompanion)",
      },
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle (CodeCompanion)" },
      { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add code to CodeCompanion" },
      {
        "<leader>ap",
        "<cmd>CodeCompanion<cr>",
        mode = "n",
        desc = "Inline prompt (CodeCompanion)",
      },
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

      -- see <https://codecompanion.olimorris.dev/configuration/action-palette.html>
      -- action_palette = {
      --   opts = {
      --     show_default_actions = false,
      --     show_default_prompt_library = false,
      --   }
      -- }
    },
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
}
