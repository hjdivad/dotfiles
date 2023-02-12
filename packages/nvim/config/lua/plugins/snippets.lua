-- TODO: snippets + completion
-- see https://github.com/folke/lazy.nvim#-plugin-spec
return {
  -- { "rafamadriz/friendly-snippets", enabled = false},
  {
    "L3MON4D3/LuaSnip",
    -- dependencies = {
    --   -- TODO: do i want this?
    --   "rafamadriz/friendly-snippets",
    --   config = function()
    --     require("luasnip.loaders.from_vscode").lazy_load()
    --   end,
    -- },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  -- stylua: ignore
  keys = {
      --TODO: delete existing lsp keymaps; in particular c-k
      --TODO: see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp
      --  init + keymaps
    {
      "<C-l>",
      function()
        return require('luasnip').expandable() and '<Plug>luasnip-expand-or-jump'
      end,
      expr = true, silent = true, mode = { "i", "s" },
    },
    { "<C-k>", function() require("luasnip").jump(1) end, mode = { "i", "s" } },
    { "<C-j>", function() require("luasnip").jump(-1) end, mode = {"i", "s"}  },
    },
  },
}
