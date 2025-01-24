local function __dirname()
  local fullpath = debug.getinfo(1, "S").source:sub(2)
  local dirname, filename = fullpath:match("^(.*/)([^/]-)$")

  return dirname, filename
end

---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
  {
    -- https://github.com/kylechui/nvim-surround#package-installation
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "S", mode = "v" },
    },
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          -- https://github.com/kylechui/nvim-surround/blob/056f69ed494198ff6ea0070cfc66997cfe0a6c8b/lua/nvim-surround/config.lua#L8-L18
          insert = false,
          insert_line = false,
          visual_line = false,
          visual = "S",
        },
      })
    end,
  },
  { "rafamadriz/friendly-snippets", enabled = false },
  -- see <~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/coding/blink.lua>
  {
    "saghen/blink.cmp",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      { "moyiz/blink-emoji.nvim" },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        list = {
          selection = {
            -- When navigating items with <c-n>, <c-p>, just show the ghost
            -- text, don't actually insert changes until the selectdion is
            -- accepted
            auto_insert = false,
          },
        },
        menu = { border = "single" },
        documentation = { window = { border = "single" } },
      },
      signature = { window = { border = "single" } },
      sources = {
        -- see <~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/ai/copilot.lua> for copilot configuration
        -- the copilot completion has a +100 offset which is why it's always the first suggestion
        --
        -- Set default to a function to return a hardcoded list and prevent
        -- lazyvim from deep merging.  This is how to remove sources (e.g.
        -- copilot or buffer)
        --
        -- default = function()
        --   return { "lsp", "path", "snippets", "emoji", "buffer" }
        -- end,
        default = { "emoji" },
        providers = {
          emoji = {
            module = "blink-emoji",
            name = "emoji",
            opts = { insert = true },
          },
          lsp = {
            score_offset = 50,
          },
          snippets = {
            score_offset = 10,
          },

          buffer = {
            -- deprioritize buffer completions, mainly to always get them below
            -- snippet completions
            score_offset = -100,
          },
        },
      },
      keymap = {
        -- prevent <cr> from selecting a completion
        preset = "none",
        -- see <https://cmp.saghen.dev/configuration/keymap#commands>
        -- lazyvim uses <c-y> "yup" which also seems fine
        ["<c-l>"] = { "show" },
        ["<c-y>"] = { "select_and_accept" },
        ["<c-n>"] = { "select_next" },
        ["<c-p>"] = { "select_prev" },
        ["<m-y>"] = { "select_and_accept" },
        ["<m-j>"] = { "select_next" },
        ["<m-k>"] = { "select_prev" },
        ["<c-j>"] = { "snippet_forward" },
        ["<c-k>"] = { "snippet_backward" },
      },
      snippets = {
        preset = "luasnip",
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,

        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,

        jump = function(direction)
          require("luasnip").jump(direction)
        end,
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    -- I use snippets everywhere so
    lazy = false,
    -- does nothing since lazy = false, but if we enable lazy loading, we
    -- should at least load luasnip when editing snippets files
    ft = "snippets",
    config = function(_, opts)
      require("luasnip").setup(opts)

      local snippets_paths = {
        "~/.config/nvim/snippets",
        __dirname() .. "/../../../../../local-packages/nvim/config/snippets",
      }
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = snippets_paths,
      })
      require("luasnip.loaders.from_lua").lazy_load({ paths = snippets_paths })

      vim.api.nvim_create_user_command("EditSnippets", function()
        require("luasnip.loaders").edit_snippet_files({})
      end, { desc = "Edit snippets used in this buffer" })
    end,
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
}
