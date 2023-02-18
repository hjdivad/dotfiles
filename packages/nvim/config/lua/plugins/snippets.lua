-- see https://github.com/folke/lazy.nvim#-plugin-spec
return {
  { "rafamadriz/friendly-snippets", enabled = false },
  -- TODO: disable lsp snippets
  {
    "L3MON4D3/LuaSnip",
    -- I use snippets everywhere so
    lazy = false,
    -- does nothing since lazy = false, but if we enable lazy loading, we
    -- should at least load luasnip when editing snippets files
    ft = "snippets",
    config = function (_plugin, opts)
      require('luasnip').setup(opts)

      local snippets_path = "~/.config/nvim/snippets"
      require('luasnip.loaders.from_snipmate').lazy_load({
        paths = snippets_path
      })
      require("luasnip.loaders.from_lua").lazy_load({paths = snippets_path})

      vim.api.nvim_create_user_command('HiEditSnippets', function()
        require('luasnip.loaders').edit_snippet_files({})
      end, { desc = 'Edit snippets used in this buffer' })
    end,
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
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
    },
  },
}
