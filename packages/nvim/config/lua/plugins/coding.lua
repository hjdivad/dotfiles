local function __dirname()
  local fullpath = debug.getinfo(1,"S").source:sub(2)
  local dirname, filename = fullpath:match('^(.*/)([^/]-)$')

  return dirname, filename
end

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
  -- TODO: disable lsp snippets
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
        __dirname() .. "/../../../../../local-packages/nvim/config/snippets"
      }
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = snippets_paths,
      })
      require("luasnip.loaders.from_lua").lazy_load({ paths = snippets_paths })

      vim.api.nvim_create_user_command("HiEditSnippets", function()
        require("luasnip.loaders").edit_snippet_files({})
      end, { desc = "Edit snippets used in this buffer" })
    end,
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = function()
      return {
        {
          "<C-k>",
          function()
            require("luasnip").jump(1)
          end,
          mode = { "i", "s" },
        },
        {
          "<C-j>",
          function()
            require("luasnip").jump(-1)
          end,
          mode = { "i", "s" },
        },
      }
    end,
  },
}
