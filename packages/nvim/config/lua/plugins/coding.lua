local function __dirname()
  local fullpath = debug.getinfo(1,"S").source:sub(2)
  local dirname, filename = fullpath:match('^(.*/)([^/]-)$')

  return dirname, filename
end

---@type LazyPluginSpec[]
return {
  -- see https://www.lazyvim.org/plugins/coding
  -- completion
  {
    -- TODO: too slow
    --  configure path (i.e. something more narrow than &path)
    --  cache (watch neotree for invalidation or maybe fswatch)
    --  Fix #88
    "hjdivad/cmp-nvim-wikilinks",
    opts = {
      -- log_level = 'trace',
      -- log_to_file = true,
      glob_suffixes = {
        "*",
        "*/*",
      },
    },
  },
  -- see $HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/coding.lua
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "hjdivad/cmp-nvim-wikilinks",
      "hrsh7th/cmp-nvim-lua", -- vim's API; would be nicer to get from lsp
    },
    keys = {
      { "<c-l>", desc = "completion" },
      -- disable imap tab from LazyVim
      { "<tab>", false },
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<c-l>"] = function()
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              cmp.complete()
            end
          end,
          ["<c-c>"] = cmp.mapping.abort(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          -- TODO: getting weird buffer keyword completion after lsp initializes
          --  `nvim packages/nvim/config/lua/chronic/init.lua`
          --    :tbldeep
          --  will complete `tbl_deep_extend`
          --    :inspi
          --  will complete Inspired (from a comment)
          --  see https://github.com/hrsh7th/cmp-nvim-lsp/blob/0e6b2ed705ddcff9738ec4ea838141654f12eeef/lua/cmp_nvim_lsp/init.lua#L37-L83
          --  This seems to be an issue with the lua lsp specifically
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          -- { name = "nvim_lua" }, -- nvim api; would rather get from lsp
          { name = "luasnip" },
          { name = "path" }, -- complete ./ &c.
          { name = "wikilinks" }, -- complete [[foo]] &c.
          { name = "emoji" }, -- complete :emoji:
        }),
        formatting = {
          format = function(_, item)
            local icons = require("lazyvim.config").icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<c-l>"] = {
            c = function()
              if cmp.visible() then
                cmp.confirm({ select = true })
              else
                cmp.complete()
              end
            end,
          },
        }),
        sources = cmp.config.sources({
          { name = "cmdline" },
          { name = "path" },
        }),
      })
    end,
  },

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
