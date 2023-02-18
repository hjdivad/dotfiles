-- TODO: snippets + completion
-- see https://github.com/folke/lazy.nvim#-plugin-spec
return {
  -- TODO: still not loading my own snippets correctly
  -- TODO: i think i'm seeing either snippets from friendly-snippets 
  --  or possibly snippets from the LSP
  --
  -- TODO: seee  lua require("luasnip.loaders").edit_snippet_files()
  { "rafamadriz/friendly-snippets", enabled = false },
  {
    "L3MON4D3/LuaSnip",
    -- dependencies = {
    --   "rafamadriz/friendly-snippets",
    --   config = function()
    --     require("luasnip.loaders.from_vscode").lazy_load()
    --   end,
    -- },
    -- I use snippets everywhere so
    lazy = false,
    -- does nothing since lazy = false, but if we enable lazy loading, we
    -- should at least load luasnip when editing snippets files
    ft = "snippets",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      -- TODO: this presumably doesn't work because it's not luasnip managing the completion;
      -- it's cmp that needs the keybinding
      -- {
      --   "<C-l>",
      --   function()
      --     local ls = require('luasnip')
      --     if ls.expandable() then
      --       ls.expand()
      --     end
      --   end,
      --   expr = true,
      --   silent = true,
      --   mode = { "i", "s" },
      -- },
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
