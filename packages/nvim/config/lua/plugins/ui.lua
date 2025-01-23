vim.g.debug_messages = false

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

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = true
      },
      win = {
        -- show the which-key window on the left
        -- see <https://github.com/folke/which-key.nvim/blob/1f8d414f61e0b05958c342df9b6a4c89ce268766/lua/which-key/view.lua#L420>
        col = 2
      }
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        mode = { "n", "v" },
        { "<leader>G", group = "+git (overflow)" },
        { "g", group = "+goto (builtin)" },
        { "]", group = "+next" },
        { "[", group = "+prev" },
        { "<leader>d", group = "+debugger" },
        { "<leader>b", group = "+buffer" },
        { "<leader>c", group = "+code" },
        { "<leader>r", group = "+refactor" },
        { "<leader>f", group = "+find" },
        { "<leader>g", group = "+goto/git" },
        { "<leader>s", group = "+search/show" },
        { "<leader>t", group = "+to" },
        { "<leader>ts", group = "+tmux session" },
        { "<leader>y", group = "+yank (to clipboard)" },
        { "<leader>n", group = "+notifications" },
        { "<leader>u", group = "+ui" },
        { "<leader>ud", group = "+ui/debug" },
        { "<leader>un", group = "+notifications" },
      })
    end,
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", false },
      { "<leader>bP", false },
    },
    opts = {
      options = {
        mode = "tabs",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("lazyvim.config").icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      -- Don't show the dashboard when starting nvim
      dashboard = {
        enabled = false,
      },
    },
  },

  -- changes how prompts are rendered and gives a lot more control over toast, popups &c.
  --
  -- Tests for these Config
  --
  -- in `./packages/nvim/test/rust/suffix_tree/src/lib.rs`
  --
  --  1. search `/asdf` (search not found)
  --  2. `<s-K>` on `assert_eq!` and `setup_logging()` (i.e. short hover and long hover)
  --  3. require('snacks.notify').warn('warning')
  --  4. quit with unsaved changes
  --
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
      ---@type NoicePresets
      presets = {
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      views = {
        minileft = {
          backend = "mini",
          relative = "editor",
          align = "message-right",
          timeout = 2000,
          reverse = true,
          focusable = false,
          position = {
            row = -1,
            col = "100%",
            -- col = 0,
          },
          size = {
            width = "auto",
            height = "auto",
            max_height = 10,
          },
          border = {
            style = "none",
          },
          zindex = 60,
          win_options = {
            winbar = "",
            foldenable = false,
            winblend = 30,
            winhighlight = {
              Normal = "NoiceMini",
              IncSearch = "",
              CurSearch = "",
              Search = "",
            },
          },
        },
      },
      -- interesting views here are
      -- popup
      -- virtualtext
      -- mini
      --
      ---@type NoiceRouteConfig[]
      routes = {
        {
          -- Use this for debugging; all messages will be logged and visible via <leader>sna
          filter = {
            cond = function(msg)
              if vim.g.debug_messages ~= true then
                return false
              end

              if msg.event == "msg_showcmd" or msg.event == "cmdline" then
                -- these events run very frequently, enough to grind nvim to a halt, so not even useful for debugging
                return false
              end
              pp({
                id = msg.id,
                event = msg.event,
                title = msg.title,
                content = msg:content(),
                kind = msg.kind,
              })
              return false
            end,
          },
        },
        -- default esg and msg_show to unobtrusive things in the bottom right;
        -- if details are needed, <leader>sna
        {
          filter = {
            event = "notify",
            kind = "info",
          },
          view = "mini",
        },
        {
          filter = {
            event = "notify",
            kind = "warn",
          },
          view = "mini",
        },
        {
          filter = {
            kind = "emsg",
          },
          view = "mini",
        },
        {
          filter = {
            event = "msg_show",
            kind = "",
          },
          view = "mini",
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      -- "scroll forward/backward"
      { "<c-f>", false },
      { "<c-b>", false },
      -- TODO: update the description on toggle (the way <leader>ua &c. do)
      {"<leader>udn", function() vim.g.debug_messages = not vim.g.debug_messages end, desc = "toggle noice message debug logging"}
    },
  },
}
