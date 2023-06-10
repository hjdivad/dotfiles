return {
  -- active indent guide and indent text objects
  {
    "echasnovski/mini.indentscope",
    opts = {
      draw = {
        -- don't animate the indent scope highlighting
        delay = 0,
      },
    },
  },

  -- Disable this growl/toast distraction
  -- use show notifications; show-last notification instead
  {
    "rcarriga/nvim-notify",
    enabled = false,
    keys = {
      {
        "<leader>un",
        false,
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },

  -- noicer ui
  {
    -- https://github.com/folke/noice.nvim#%EF%B8%8F-configuration
    -- https://github.com/folke/noice.nvim#-filters
    -- https://github.com/folke/noice.nvim#-views
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
      routes = {
        {
          filter = {
            kind = "search_count",
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            kind = "return_prompt",
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d changes?;"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "--No lines in buffer--"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d lines? >ed"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d lines? <ed"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d more lines?"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d fewer lines?"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d line? less"
          },
          opts = {
            skip = true,
          },
        },
        {
          filter = {
            find = "%d lines? yanked"
          },
          view = "mini",
        },
        {
          filter = {
            find = "Already at oldest change"
          },
          view = "mini",
        },
        {
          filter = {
            find = "Already at newest change"
          },
          view = "mini",
        },
        {
          filter = {
            find = "search hit BOTTOM",
          },
          view = "mini",
        },
        {
          filter = {
            find = "Pattern not found",
          },
          view = "mini",
        },

        {
          -- use print('debug ${msg}') to skip popups for printf-debugging
          filter = {
            find = "debug .*",
          },
          view = "mini",
        },

        {
          -- default messages to a popup that can be closed with q
          -- this is really annoying for useless messages, so it's best to remap them to `silent!`
          -- but it's way better when you actually care about reading what the message says
          filter = {
            event = "msg_show",
          },
          view = "mini",
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", false},
      { "<leader>snh", false},
      { "<leader>sna", false},
      { "<c-f>", false },
      { "<c-b>", false },
      { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>unl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>unh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>una", function() require("noice").cmd("all") end, desc = "Noice All" },
    },
  },
}
