return {
  -- TODO: see https://github.com/hjdivad/dotfiles/blob/ba25ed22c114ddbaeeb6ed919659a319a727f845/packages/nvim/config/lua/hjdivad/init.lua#L593-L633
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
      }
    }
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
      { "<c-l>", desc="completion" }
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            -- TODO: i don't get why lsp_expand vs expand
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
        -- TODO: something's wrong here, we're still completing the local buffer
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lua" }, -- nvim api; would rather get from lsp
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
}
