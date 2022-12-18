local is_headless = #vim.api.nvim_list_uis() == 0
local in_ci = vim.env.CI == 'true'

local function plugin_config(use)
  ---core setup

  use 'wbthomason/packer.nvim' -- nvim package manager
  use {
    'malleatus/common.nvim', -- shared nvim config
    config = function() require('malleatus').setup {} end
  }

  use 'nvim-lua/popup.nvim' -- create floating windows over other windows
  use 'nvim-lua/plenary.nvim' -- lots of lua utilities

  use {
    'nvim-treesitter/nvim-treesitter', -- general family of incremental parsers
    config = function()
      if not in_ci then
        require('nvim-treesitter.configs').setup {
          highlight = {
            enable = true,
            disable = {
              -- TODO: re-eanble these?
              'lua',
              'vim',
            }
          },
          indent = {
            enable = true
          }
        }
      end
    end,
    run = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        -- install sync when bootstrapping headlessly so we can rely on exit code
        sync_install = is_headless
      }
    end
  }

  ---Simple plugins

  use 'tpope/vim-sensible' -- additional defaults beyond nocompatible
  use 'tpope/vim-surround' -- edit inner/outer surroundings (e.g. di" to delete text between quotes)
  use 'tpope/vim-unimpaired' -- more mappings
  use 'tpope/vim-repeat' -- make . (repeat) available to plugins
  use 'tpope/vim-commentary' -- gcc to toggle comment
  use {
    'bcaccinolo/bclose', -- Bclose (delete buffer without affecting windows)
    config = function()
      -- disable default mappings
      vim.g.bclose_no_default_mapping = true
    end
  }
  -- i don't use this directly but i think it is (or was) a dep of some other plugin
  use 'godlygeek/tabular' -- align text :Tabularize /<sep>,<formatstr>

  ---Generic plugins

  use {
    'kyazdani42/nvim-tree.lua', -- file explorer
    config = function()
      require('nvim-tree').setup {
        view = {
          mappings = {
            custom_only = true,
            list = {
              --- default mappings
              -- copied from :nvim-tree-mappings
              -- custom mappings seem to only work with custom_only=true
              { key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
              { key = "<C-e>", action = "edit_in_place" },
              { key = { "O" }, action = "edit_no_picker" },
              { key = { "<2-RightMouse>", "<C-]>" }, action = "cd" },
              { key = "<C-v>", action = "vsplit" },
              { key = "<C-x>", action = "split" },
              { key = "<C-t>", action = "tabnew" },
              { key = "<", action = "prev_sibling" },
              { key = ">", action = "next_sibling" },
              { key = "P", action = "parent_node" },
              { key = "<BS>", action = "close_node" },
              { key = "<Tab>", action = "preview" },
              { key = "K", action = "first_sibling" },
              { key = "J", action = "last_sibling" },
              { key = "I", action = "toggle_git_ignored" },
              { key = "H", action = "toggle_dotfiles" },
              { key = "R", action = "refresh" },
              { key = "a", action = "create" },
              { key = "d", action = "remove" },
              { key = "D", action = "trash" },
              { key = "r", action = "rename" },
              { key = "<C-r>", action = "full_rename" },
              { key = "x", action = "cut" },
              { key = "c", action = "copy" },
              { key = "p", action = "paste" },
              { key = "y", action = "copy_name" },
              { key = "Y", action = "copy_path" },
              { key = "gy", action = "copy_absolute_path" },
              { key = "[c", action = "prev_git_item" },
              { key = "]c", action = "next_git_item" },
              { key = "-", action = "dir_up" },
              { key = "s", action = "system_open" },
              { key = "q", action = "close" },
              { key = "g?", action = "toggle_help" },
              { key = 'W', action = "collapse_all" },
              { key = "S", action = "search_node" },
              { key = ".", action = "run_file_command" },
              { key = "<C-k>", action = "toggle_file_info" },
              { key = "U", action = "toggle_custom" },
              --- custom mappings
              {
                key = '<leader>fr',
                action = '',
                action_cb = function(node)
                  require('telescope.builtin').grep_string({ search = '', search_dirs = { node.absolute_path } })
                end
              },
            }
          },
        },
        renderer = {
          highlight_opened_files = 'all', -- highlight files opened in a buffer
          group_empty = true, -- group folders that only contain one other folder (com/whatever/java/so/annoying &c.)
        },
        diagnostics = { enable = true, show_on_dirs = true },
        update_focused_file = {
          enable = true, -- highlight focused file in NVIMTree
          update_cwd = false
        },
        -- :h nvinm-tree.filters for additional file hiding
        actions = {
          open_file = {
            quit_on_open = true, -- close tree when opening a file
            window_picker = {
              enable = false -- open files in last focused window
            }
          }
        }
      }
    end
  }
  use 'sharkdp/fd' -- alternative file finder
  use {
    'nvim-telescope/telescope.nvim', -- configurable list fuzzy matcher
    requires = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()

      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-k>'] = 'move_selection_previous',
              ['<C-j>'] = 'move_selection_next',
              ['<C-h>'] = 'which_key',
            },
          }
        },

        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_cursor {}
          }
        },
      }
      telescope.load_extension('fzf') -- use fzf over fzy to get operators
      -- see
      -- <https://github.com/nvim-telescope/telescope-ui-select.nvim#telescope-setup-and-configuration>
      -- for configuring new prompts
      telescope.load_extension('ui-select') -- use telescope for selecting prompt choices
    end
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    requires = 'nvim-telescope/telescope.nvim'
  }
  use 'nvim-telescope/telescope-ui-select.nvim' -- use telescope to select choices
  use 'camgraff/telescope-tmux.nvim' -- telescope tmux search

  if not in_ci then
    --TODO: try heirline see if it's nicer & faster than airline
    use {
      -- status line
      'vim-airline/vim-airline',
      config = function()
        -- see <https://github.com/vim-airline/vim-airline>
        -- see :h airline-configuration
        vim.o.laststatus = 2 -- always show status line
        vim.g.airline_highlighting_cache = 1

        -- don't search runtimepath for extensions; be explicit about what's loaded
        -- this list is the default sans 'whitespace', which I leave to linters
        vim.g.airline_extensions = {
          'branch', 'fugitiveline', 'hunks', 'keymap', 'netrw', 'nvimlsp', 'po', 'quickfix',
          'searchcount', 'term', 'wordcount'
        }
      end
    }
    use { 'vim-airline/vim-airline-themes' } -- status lines themes
  end

  ---Git

  use 'tpope/vim-fugitive' -- tpope's git integration (blame, navigation &c.)
  use 'tpope/vim-rhubarb' -- make fugitive's GBrowse work
  use 'tpope/vim-git' -- git syntax &c.

  if not in_ci then
    use {
      'airblade/vim-gitgutter', -- show line-level git diff in the gutter
      config = function()
        -- TODO: this can be made more robust (handle origin/main + maybe toggle against upstreams)
        vim.g.gitgutter_diff_base = 'origin/master'
        vim.g.gitgutter_map_keys = 0
      end
    }
  end

  ---Terminal

  use 'wincent/terminus' -- improved terminal support
  use {
    'kassio/neoterm', -- Topen &c.
    config = function()
      -- TODO: move to malleatus
      require('hjdivad/terminal').setup { mappings = true }
    end
  }

  ---Testing

  use {
    'vim-test/vim-test', -- test runner integration
    config = function()
      require('hjdivad/testing').setup_vimtest()
    end
  }

  ---Colourscheme & Icons

  use 'joshdick/onedark.vim' -- colourscheme rob+stef use
  use 'kyazdani42/nvim-web-devicons' -- add filetype icons
  -- TODO: this doesn't seem to add icons for completion via cmp
  use {
    'yamatsum/nvim-nonicons', -- more icons
    config = function()
      local icons = require('nvim-nonicons')

      icons.get('file')
    end
  }
  use 'folke/lsp-colors.nvim' -- add LSP diagnostic highlights

  ---Treesitter

  use 'nvim-treesitter/playground' -- show treesitter parse tree in a buffer
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- create user-textobjects using treesitter

  ---Language servers (LSP)

  use {
    'neovim/nvim-lspconfig', -- native lsp
    config = function()
      -- for more see <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md>

      -- TODO: flesh out vim api lsp config into a plugin
      -- Dead code at runtime, but parsed by sumneko (lua LSP)
      -- useful in plugin-dev
      if false then
        vim.keymap = require('vim.keymap')
        vim.lsp = require('vim.lsp') -- goto-def doesn't wokr here but it does on keymap?
        vim.fn = require('vim.fn')
        vim.lsp.buf = vim.lsp.buf or require('vim.lsp.buf')
      end

      local function setup_lsp_mappings()
        vim.keymap.set('n', 'K', function()
          -- see <https://github.com/glepnir/lspsaga.nvim> to enable scrolling in
          -- window. It's not clear how to focus the window
          require('lspsaga.hover'):render_hover_doc()
        end, { desc = 'Show LSP hover (fn docs, help &c.)', })
        vim.keymap.set('n', '<c-h>', function()
          require('lspsaga.signaturehelp'):signature_help()
        end, { desc = 'Show LSP signature help', })

        vim.keymap.set('n', '<leader>gg', function()
          require('lspsaga.finder'):lsp_finder()
        end, { desc = 'go go go (to something, defintion, references, &c.)', })
        vim.keymap.set('n', '<leader>gd', function()
          require('telescope.builtin').lsp_definitions()
        end, { desc = 'go to definition', })
        vim.keymap.set('n', '<leader>gD', function()
          require('telescope.builtin').lsp_type_definitions()
        end, { desc = 'go to type definition', })
        vim.keymap.set('n', '<leader>gi', function()
          require('telescope.builtin').lsp_implementations()
        end, { desc = 'go to implementations', })
        vim.keymap.set('n', '<leader>gr', function()
          require('telescope.builtin').lsp_references()
        end, { desc = 'go to references', })
        vim.keymap.set('n', '<leader>gl', function()
          vim.cmd('cope')
        end, { desc = 'go to linting diagnostics', })
        vim.keymap.set('n', '<leader>gci', vim.lsp.buf.incoming_calls,
          { desc = 'go to calls (inbound) -- who calls me?', })
        vim.keymap.set('n', '<leader>gco', vim.lsp.buf.outgoing_calls,
          { desc = 'go to calls (outbound) -- who do i call?', })

        vim.keymap.set('n', '<leader>ss', function() require('telescope.builtin').lsp_document_symbols() end,
          { desc = 'show document symbols', })
        vim.keymap.set('n', '<leader>sS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
          { desc = 'show workspace symbols', })
        vim.keymap.set('n', '<leader>SS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
          { desc = 'show workspace symbols', })
        vim.keymap.set('n', '<leader>sf',
          function() require('telescope.builtin').lsp_document_symbols({ symbols = { 'function' } }) end,
          { desc = 'show functions', })
        vim.keymap.set('n', '<leader>so', '<cmd>LSoutlineToggle<cr>', { desc = 'show outline', })
        vim.keymap.set('n', '<leader>sd', function() require('lspsaga.definition'):preview_definition() end,
          { desc = 'show definition preview', })

        vim.keymap.set('n', '<leader>ca', function()
          --TODO: this is a little bugged; code action on the same spot will keep
          --increasing the list of code action choices
          require('lspsaga.codeaction'):code_action()
        end, { desc = 'list code actions under cursor' })
        vim.keymap.set('v', '<leader>ca', function()
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, false, true))
          require('lspsaga.codeaction'):range_code_action()
        end, { desc = 'list code actions in range' })

        vim.keymap.set('n', '<leader>rn', function()
          require('lspsaga.rename'):lsp_rename()
        end, { desc = 'rename symbol under cursor' })

        vim.keymap.set('n', '<leader>rf', function()
          ---@diagnostic disable-next-line: missing-parameter
          vim.lsp.buf.formatting_seq_sync()
        end, { desc = 'format buffer' })

        vim.keymap.set('i', '<c-h>', function()
          require('lspsaga.signaturehelp'):signature_help()
        end, { desc = 'show signature help' })

        -- TODO: this works but we don't have control over the specific server used
        -- This is particularly unfortunate as TypeScript claims it can format, but
        -- we want diagnosticls to actually do so
        vim.keymap.set('v', '<leader>rf', function()
          local vis_start = vim.api.nvim_buf_get_mark(0, '<')
          local vis_end = vim.api.nvim_buf_get_mark(0, '>')
          vim.pretty_print('range fmt', vis_start, vis_end)
          vim.lsp.buf.range_formatting({}, vis_start, vis_end)
          -- send <esc> to exit visual mode after formatting
          local escape = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
          vim.api.nvim_feedkeys(escape, 'n', false)
        end, { desc = 'Format selected range' })
      end

      local function on_lsp_attach()
        -- setup LSP keymappings
        setup_lsp_mappings()

        -- use LSP for omnifunc
        -- trigger via i_CTRL-X_CTRL-O
        vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- use LSP for formatxpr
        vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

        -- disabled format on save until I can get it to play nice with folding
        -- if vim.fn.exists('b:formatter_loaded') == 0 then
        --   vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
        --   vim.api.nvim_buf_set_var(0, 'formatter_loaded', true)
        -- end

        -- for plugins with `on_attach` call them here
      end

      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- list of configurations at <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md>
      local lsp = require 'lspconfig'

      -- TODO: nmap gf <leader>gd ? this actually works in e.g. this repo
      -- unclear how best to do this on lsp_attach but it could also be a function that does one or the other based on whether lsp is attached
      local runtime_path = vim.split(package.path, ';')
      table.insert(runtime_path, 'lua/?.lua')
      table.insert(runtime_path, 'lua/?/init.lua')
      lsp.sumneko_lua.setup {
        capabilities = capabilities,
        cmd = { 'lua-language-server' },
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
              path = runtime_path,
            },
            diagnostics = {
              globals = { 'vim' }
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true)
            },
            telemetry = {
              enable = false
            }
          }
        },

        on_attach = on_lsp_attach
      }

      lsp.tsserver.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.rust_analyzer.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.vimls.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.jsonls.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.graphql.setup { capabilities = capabilities, on_attach = on_lsp_attach }


      lsp.html.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.cssls.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.yamlls.setup {
        capabilities = capabilities,
        on_attach = on_lsp_attach,
        schemas = {
          -- per-file modelines look like
          -- # yaml-language-server: $schema=<urlToTheSchema|relativeFilePath|absoluteFilePath}>
          --
          -- Otherwise patterns can be added here
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        }
      }

      lsp.bashls.setup { capabilities = capabilities, on_attach = on_lsp_attach }


      lsp.ccls.setup { capabilities = capabilities, on_attach = on_lsp_attach }

      lsp.pylsp.setup { capabilities = capabilities, on_attach = on_lsp_attach }


      local linters = {
        eslint = {
          sourceName = 'eslint',
          -- TODO: try https://github.com/mantoni/eslint_d.js/
          command = 'eslint',
          debounce = 100,
          args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
          parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${ruleId}]",
            security = "severity"
          },
          securities = { [2] = "error", [1] = "warning" },
          rootPatterns = {
            '.eslintrc',
            '.eslintrc.cjs',
            '.eslintrc.js',
            '.eslintrc.json',
            '.eslintrc.yaml',
            '.eslintrc.yml',
          }
        }
      }

      local formatters = {
        prettier = { command = "prettier", args = { "--stdin-filepath", "%filepath" } }
      }

      -- see <https://github.com/iamcco/diagnostic-languageserver>
      lsp.diagnosticls.setup {
        filetypes = { 'typescript', 'javascript', 'markdown', 'graphql' },
        init_options = {
          linters = linters,
          filetypes = { typescript = 'eslint', javascript = 'eslint' },
          formatters = formatters,
          formatFiletypes = { typescript = 'prettier', javascript = 'prettier', markdown = 'prettier',
            graphql = 'prettier' }
        }
      }
    end
  }

  ---Diagnostics & formatting

  use {
    'glepnir/lspsaga.nvim', -- nice ui for vim.diagnostic
    config = function()

      require('lspsaga').init_lsp_saga({
        move_in_saga = {
          prev = 'k',
          ['next'] = 'j',
        },
        finder_action_keys = {
          open = '<cr>',
          quit = '<C-c>',
        },
        code_action_keys = {
          exec = '<cr>',
          quit = '<C-c>',
        },
      })
    end
  }
  use 'editorconfig/editorconfig-vim' -- support for editrconfig shared configs beyond vim

  ---Completion & snippets

  -- TODO: consider luasnips?
  -- <https://github.com/L3MON4D3/LuaSnip>
  -- examples: <https://github.com/molleweide/LuaSnip-snippets.nvim/tree/main/lua/luasnip_snippets/snippets>
  use {
    'SirVer/ultisnips', -- snippets
    config = function()
      -- reverse the default ultisnip movement triggers
      vim.g.UltiSnipsJumpForwardTrigger = '<c-k>'
      vim.g.UltiSnipsJumpBackwardTrigger = '<c-j>'
    end
  }

  -- TODO: try https://github.com/hrsh7th/cmp-copilot
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require('cmp')
      require('cmp_nvim_wikilinks').setup {}

      cmp.setup {
        snippet = { expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end },
        mapping = {
          ['<c-l>'] = cmp.mapping.confirm({ select = true }),
          ['<c-c>'] = cmp.mapping.abort(),
          ['<c-n>'] = cmp.mapping.select_next_item(),
          ['<c-p>'] = cmp.mapping.select_prev_item(),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources({
          { name = 'ultisnips' }, -- UltiSnipsEdit + UltiSnipsAddFileTypes
          { name = 'nvim_lsp' }, -- complete symbols (via LSP)
          { name = 'nvim_lsp_signature_help' }, -- signature completion
          { name = 'nvim_lua' }, -- lua nvim api completion (vim.lsp.* &c.)
          -- This is useful when there is no LSP, but with an LSP + snippets it's mostly noise
          -- { name = 'buffer' }, -- autocomplete keywords (&isk) in buffer
          { name = 'path' }, -- trigger via `/` or '.'
          { name = 'wikilinks' }, -- complete obsidian-style wikilinks against &path
          { name = 'emoji' }, -- trigger via `:` in insert mode
        })
      }

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline({
          ['<c-l>'] = {
            c = function()
              if cmp.visible() then
                cmp.confirm({ select = true })
              end
            end,
          }
        }),
        sources = cmp.config.sources({
          { name = 'cmdline' },
          { name = 'path' }
        })
      })

      -- see <https://github.com/hrsh7th/nvim-cmp#setup>
      --  can setup per filetype
      --    cmp.setup.filetype('myfiletype', {})
      --  can setup per custom LSP
    end
  }
  use 'hrsh7th/cmp-nvim-lsp' -- complete by lsp symbols
  use 'hrsh7th/cmp-path' -- complete file paths
  use 'hrsh7th/cmp-cmdline' -- /@ searches this buffer's document symbols
  use 'quangnguyen30192/cmp-nvim-ultisnips' -- complete by UltiSnips snippets
  use 'hrsh7th/cmp-nvim-lsp-signature-help' -- complete fn args &c.
  use 'hrsh7th/cmp-emoji' --complete emoji
  use 'hrsh7th/cmp-nvim-lua' --complete neovim's runtime api `vim.lsp.*` &c.
  use 'hrsh7th/cmp-nvim-lsp-document-symbol' -- /@ search buffer for LSP document symbols
  use 'hjdivad/cmp-nvim-wikilinks' -- complete filenames against &path in [[wikilinks]]

  ---Filetype specific

  use 'euclidianAce/BetterLua.vim' -- improved Lua syntax highlighting
  use 'hjdivad/vim-pdl' -- extremely primitive PDL support
  use 'jparise/vim-graphql' -- syntax highlighting for graphql
  use 'gutenye/json5.vim' -- syntax highlighting for json5
  use {
    'preservim/vim-markdown', -- i use this for folding only
    config = function()
      -- add more aliases here for syntax highlighted code fenced blocks
      vim.g.markdown_fenced_languages = { 'js=javascript', 'ts=typescript' }

      vim.g.vim_markdown_no_extensions_in_markdown = 1 -- assume links like foo mean foo.md
      vim.g.vim_markdown_follow_anchor = 1 -- follow anchors in links like foo.md#wat
      vim.g.vim_markdown_frontmatter = 1 -- highlight YAML frontmatter
      vim.g.vim_markdown_strikethrough = 1 -- add highlighting for ~~strikethrough~~
      vim.g.markdown_auto_insert_bullets = 0 -- don't insert bullets in insert mode; I prefer to use snippets
      vim.g.vim_markdown_new_list_item_indent = 0 -- don't insert bullets in insert mode; I prefer to use snippets
    end
  }
  use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' } -- preview rendered markdown in browser


  ---Plugins to try
  ---
  -- TODO: try https://github.com/pwntester/octo.nvim
  -- TODO: try https://github.com/nvim-telescope/telescope-github.nvim
  -- TODO: try https://github.com/AckslD/nvim-neoclip.lua
  -- TODO: try https://github.com/sudormrfbin/cheatsheet.nvim
  -- TODO: try https://github.com/mfussenegger/nvim-dap
  --  see <https://github.com/stefanpenner/dotfiles/blob/64df5a20ca0c9b3df0e4ea262b7cb7486e86a9ed/.config/nvim/init.lua#L171-L186>
  -- TODO: https://github.com/rcarriga/nvim-dap-ui
  -- TODO: try https://github.com/nvim-telescope/telescope-dap.nvim
  -- TODO: try https://github.com/puremourning/vimspector
  -- TODO: try https://github.com/nvim-telescope/telescope-vimspector.nvim
  -- TODO: try https://github.com/jvgrootveld/telescope-zoxide
  -- TODO: try https://github.com/ajeetdsouza/zoxide
  -- TODO: try 'gh.nvim'
end

return plugin_config
