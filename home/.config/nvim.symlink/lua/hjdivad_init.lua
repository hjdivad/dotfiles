-- TODO: bootstrap check + provide bootstrap.lua for new boxes

local h = require('hjdivad/main')
local plugins = require('hjdivad/plugins')
local hjdivad = h

-- the global namespace, for adding userland hooks like `plugins`
-- as well as entry points for autocommands
local hi = hjdivad.hjdivad_init

local map      = hjdivad.map
local nmap     = hjdivad.nmap
local nnoremap = hjdivad.nnoremap
local imap     = hjdivad.imap
local tnoremap = hjdivad.tnoremap
local nmaptb   = hjdivad.nmaptb
local unmap    = hjdivad.unmap
local maptb    = hjdivad.maptb

local function setup_local_config()
  ---spelling
  vim.opt.spelllang = { 'sv', 'en_gb', 'en_us' }
  vim.opt.spellfile = {
    '.vimspell.utf8.add', '~/.local/share/.nvim/spell/en.utf-8.add',
    '~/.local/share/.nvim/spell/sv.utf-8.add'
  }
end

local function setup_clipboard()
  vim.o.clipboard = 'unnamed,unnamedplus' -- always yank &c. to clipboard

  local env = vim.env

  if env.SSH_TTY ~= nil or env.SSH_CLIENT ~= nil then
    -- remote terminal, yank to client clipboard
    -- this requires:
    --  1. remote port forwarding (-R) when connecting to the remote server and
    --  2. a config on the server for `client` that knows about the port and
    --  3. the server being able to ssh to the client
    vim.g.clipboard = {
      name = 'ssh-pbcopy',
      copy = { ['+'] = 'ssh client pbcopy', ['*'] = 'ssh client pbcopy' },
      paste = { ['+'] = 'ssh client pbpaste', ['*'] = 'ssh client pbpaste' },
      cache_enabled = true
    }
  end
end

local function setup_colours()
  vim.o.termguicolors = true

  vim.cmd 'silent! colorscheme onedark'
  -- onedark doesn't specify undercurls
  -- TODO: change the coloring to nvim_create_autocmd for ColorScheme
  vim.cmd([[
    hi DiagnosticUnderlineError gui=undercurl
    hi DiagnosticUnderlineHint gui=undercurl
    hi DiagnosticUnderlineInfo gui=undercurl
    hi DiagnosticUnderlineWarn gui=undercurl

    hi SpellBad gui=undercurl

    hi markdownTSStrong guifg=#E5C07B cterm=bold gui=bold       " guifg=Type
    hi markdownTSEmphasis guifg=#C678DD cterm=italic gui=italic " guifg=Question
    " TODO: add highlights for cmp-highlight
  ]])
end

local function setup_statusline()
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

local function setup_mappings()
  -- TODO: could make this idempotent?
  vim.keymap.del('n', 'Y') -- neovim 0.6.0 maps Y to "$ by default (see default-mappings)

  vim.keymap.set('n', 'Q', '', { desc = 'disable Ex mode from Q (unhelpful fat-finger trap)', })
  vim.keymap.set('n', 'j', 'gj', { desc = 'move (visual) row-wise instead of line-wise', })
  vim.keymap.set('n', 'k', 'gk', { desc = 'move (visual) row-wise instead of line-wise', })


  vim.keymap.set('n', '<leader><leader>', '<cmd>nohl | checktime<cr>', { desc = 'use ,, to clear highlights', })

  vim.keymap.set('n', '<leader>nf', h.toggle_nvim_tree, { desc = 'now files (toggle nvim-tree)', })
  vim.keymap.set('n', '<leader>nt', h.toggle_terminal, { desc = 'now terminal (intelligent neoterm toggling)', })

  nnoremap([[']], '`') -- 'x is much easier to hit than `x and has more useful semantics: ie switching
  -- to the column of the mark as well as the row

  nmaptb('<leader>ff', 'find_files()') -- find files relative to cwd
  nmaptb('<leader>fF', 'find_files({ hidden=true, no_ignore=true })') -- find (more) files
  nmaptb('<leader>fg', 'git_files()') -- find files in git
  -- TODO: improve this; get files from git diff <upstream>
  nmaptb('<leader>fs', 'git_status()') -- find files mentioned by git status
  nmaptb('<leader>fc', 'git_commits()') -- find (git) commit
  nmaptb('<leader>fm', 'marks()') -- find marks
  nmaptb('<leader>fb', 'buffers()') -- find opened files (in buffers)
  -- TODO: use rg + fuzzy matching instead of builtin live grep
  nmaptb('<leader>fr', [[grep_string({ search='' })]]) -- fuzzy search against ~ rg .
  -- TODO: nice to add a (current_class_fuzzy_find, current_method_fuzzy_find &c.) using treesitter
  -- or perhaps using text objects? fuzzy_find_lines_in_text_objects <af> a function
  nmaptb('<leader>fi', 'current_buffer_fuzzy_find()') -- find (fuzzy) in current buffer
  nmap('<leader>fa', '<cmd>Telescope<cr>', { silent = true }) -- find anything (pick a picker)
  nmaptb('<leader>fh', 'help_tags()') -- find vim help

  nmap('<leader>ll', '<cmd>Trouble document_diagnostics<cr>') -- lint list
  nmap('<leader>lL', '<cmd>Trouble workspace_diagnostics<cr>') -- lint list (more)

  -- TODO: these two (ln, lp) seem to be broken in nvim 0.7.0
  nmap('<leader>ln', [[<cmd>lua require('trouble').next({ skip_groups = true, jump = true })<cr>]]) -- lint next
  nmap('<leader>lp',
    [[<cmd>lua require('trouble').previous({ skip_groups = true, jump = true })<cr>]]) -- lint prev

  -- see https://github.com/nvim-telescope/telescope-symbols.nvim#symbol-source-format
  -- for custom symbols / symbol names
  imap('<C-f>', [[<Cmd>lua require('cmp').complete()<cr>]], { silent = true }) -- manually trigger completion

  nmap('<leader>bd', '<cmd>Bclose<cr><cmd>enew<cr>')

  nmap('<leader>hn', '<cmd>GitGutterNextHunk<cr>')
  nmap('<leader>hp', '<cmd>GitGutterPrevHunk<cr>')
  nmap('<leader>hP', '<cmd>GitGutterPreviewHunk<cr>')
  nmap('<leader>hu', '<cmd>GitGutterUndoHunk<cr>')

  nmap('<leader>ts', [[<Cmd>Telescope tmux windows<cr>]])
  nmap('<leader>tt', [[<Cmd>silent !tmux switch-client -l<cr>]])
  nmap('<leader>td', [[<Cmd>lua ha.goto_tmux_session('todos', 'todos')<cr>]])
  nmap('<leader>tr', [[<Cmd>lua ha.goto_tmux_session('todos', 'reference')<cr>]])
  nmap('<leader>tj', [[<Cmd>lua ha.goto_tmux_session('todos', 'journal')<cr>]])

  ---Mapping for opening up a generic REPL buffer + terminal pair.
  ---In general it's recommended to overwrite this mapping per-project with a
  ---specific repl command and repl file, for example:
  ---```lua
  ---vim.api.nvim_set_keymap('n', '<leader>re', [[<cmd>ha.edit_repl('yarn repl', 'ts')]]<cr>')
  ---```
  nmap('<leader>re', '<cmd>lua ha.edit_generic_repl()<cr>')
  map('v', '<leader>re', ':TREPLSendSelection<cr>', {})
  nmap('<leader>rr', '<cmd>TestFile<cr>')
  nmap('<leader>rt', '<cmd>TestNearest<cr>')
  nmap('<leader>rd', '<cmd>lua ha.debug_nearest()<cr>')

  --- yank file [path] to clipboard, using the best register we have available
  if vim.fn['has']('clipboard') then
    nmap('<leader>yf', [[<cmd>let @+=expand('%')<cr>]]) -- yank path to clipboard
    nmap('<leader>yF', [[<cmd>let @+=expand('%:p')<cr>]]) -- yank absolute path to clipboard
  else
    nmap('<leader>yf', [[<cmd>let @"=expand('%')<cr>]]) -- yank path to clipboard
    nmap('<leader>yF', [[<cmd>let @"=expand('%:p')<cr>]]) -- yank absolute path to clipboard
  end

  tnoremap('<c-g><c-g>', [[<c-\><c-n>]]) -- better terminal escape to normal mapping

  ---terminal window motions
  tnoremap('<c-w>h', [[<c-\><c-n><c-w>h]])
  tnoremap('<c-w><c-h>', [[<c-\><c-n><c-w>h]])
  tnoremap('<c-w>j', [[<c-\><c-n><c-w>j]])
  tnoremap('<c-w><c-j>', [[<c-\><c-n><c-w>j]])
  tnoremap('<c-w>k', [[<c-\><c-n><c-w>k]])
  tnoremap('<c-w><c-k>', [[<c-\><c-n><c-w>k]])
  tnoremap('<c-w>l', [[<c-\><c-n><c-w>l]])
  tnoremap('<c-w><c-l>', [[<c-\><c-n><c-w>l]])
  tnoremap('<c-w>c', [[<c-\><c-n><c-w>c]])
  tnoremap('<c-w><c-c>', [[<c-\><c-n><c-w>c]])

  -- escape and re-enter insert mode to prevent issue with cursor not appearing in new terminal window
  tnoremap('<c-w>n', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]])
  tnoremap('<c-w><c-n>', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]])

  --- tab navigation
  vim.keymap.set('n', '<leader>1', '1gt', { desc = 'go to tab 1', })
  vim.keymap.set('n', '<leader>2', '2gt', { desc = 'go to tab 2', })
  vim.keymap.set('n', '<leader>3', '3gt', { desc = 'go to tab 3', })
  vim.keymap.set('n', '<leader>4', '4gt', { desc = 'go to tab 4', })
  vim.keymap.set('n', '<leader>5', '5gt', { desc = 'go to tab 5', })
  vim.keymap.set('n', '<leader>6', '6gt', { desc = 'go to tab 6', })
  vim.keymap.set('n', '<leader>7', '7gt', { desc = 'go to tab 7', })
  vim.keymap.set('n', '<leader>8', '8gt', { desc = 'go to tab 8', })
  vim.keymap.set('n', '<leader>9', '9gt', { desc = 'go to tab 9', })
  vim.keymap.set('n', '<leader>0', '10gt', { desc = 'go to tab 10', })

  -- yank GitHub permalink to clipboard
  vim.keymap.set('v', '<leader>yg', ':GBrowse!<cr>', { silent = true, desc = 'Yank GitHub permalink to clipboard' })
end

local function setup_lsp_mappings()
  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { noremap = true })
  map('n', '<c-h>', [[<cmd>lua vim.lsp.buf.signature_help()<cr>]], { silent = true })

  ---telescope variant
  -- maptb('n', '<leader>gd', 'lsp_definitions()') -- go to definition
  -- maptb('n', '<leader>gD', 'lsp_type_definitions()') -- go to type definition
  -- maptb('n', '<leader>gi', 'lsp_implementation()') -- go to implementation
  -- maptb('n', '<leader>gr', 'lsp_references()') -- go to reference(s)

  ---trouble variant
  -- see <https://github.com/folke/trouble.nvim/issues/153>
  -- nmap('<leader>gd', '<cmd>Trouble lsp_definitions<cr>') -- go to definition
  maptb('n', '<leader>gd', 'lsp_definitions()') -- list document symbols
  nmap('<leader>gD', '<cmd>Trouble lsp_type_definitions<cr>') -- go to type definition
  nmap('<leader>gi', '<cmd>Trouble lsp_implementation<cr>') -- go to implementation
  nmap('<leader>gr', '<cmd>Trouble lsp_references<cr>') -- go to reference(s)
  -- useful for exploring multiple results e.g. multiple references
  nmap('<leader>gt', '<cmd>TroubleToggle<cr>') -- toggle trouble window

  nmap('<leader>gci', '<cmd>lua vim.lsp.buf.incoming_calls()<cr>') -- who calls this function?
  nmap('<leader>gco', '<cmd>lua vim.lsp.buf.outgoing_calls()<cr>') -- who does this function call?

  maptb('n', '<leader>ss', 'lsp_document_symbols()') -- list document symbols
  maptb('n', '<leader>sS', 'lsp_dynamic_workspace_symbols()') -- list workspace symbols
  maptb('n', '<leader>SS', 'lsp_dynamic_workspace_symbols()') -- list workspace symbols
  maptb('n', '<leader>sf', [[lsp_document_symbols({ symbols={'function'} })]]) -- list document symbols
  maptb('n', '<leader>so', [[lsp_document_symbols({ symbols={'class', 'function'} })]]) -- list document symbols
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'list code actions under cursor' })
  -- TODO: this gets a stacktrace; try again in nvim >= 0.6.2
  -- maptb('v', '<leader>ca', 'lsp_range_code_actions()') -- list code actions (selected)

  nmap('<leader>rn', [[<cmd>lua vim.buf.rename()<cr>]], { silent = true }) -- rename

  imap('<c-h>', [[<cmd>lua vim.lsp.buf.signature_help()<cr>]], { silent = true })


  vim.keymap.set('v', '<leader>rf', function()
    local vis_start = vim.api.nvim_buf_get_mark(0, '<')
    local vis_end = vim.api.nvim_buf_get_mark(0, '>')
    vim.lsp.buf.range_formatting({}, vis_start, vis_end)
    -- it would be nice to exit visual mode here. The following works:
    --  :lua vim.cmd('stopinsert')
    -- so it's not obvious to me why it wouldn't work in a callback
    -- vim.cmd('stopinsert')
  end)
end

local function setup_language_servers()
  -- for more see <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md>

  local function on_lsp_attach()
    -- setup LSP keymappings
    setup_lsp_mappings()

    -- use LSP for omnifunc
    -- trigger via i_CTRL-X_CTRL-O
    vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- use LSP for formatxpr
    vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- TODO: see :he vim.lsp.buf.range_formatting()
    if vim.fn['exists']('b:formatter_loaded') == 0 then
      vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
      vim.api.nvim_buf_set_var(0, 'formatter_loaded', true)
    end

    -- for plugins with `on_attach` call them here
  end

  -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  -- list of configurations at <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md>
  local lsp = require 'lspconfig'

  lsp.sumneko_lua.setup {
    capabilities = capabilities,
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';')
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' }
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
          }
        }
      }
    },

    on_attach = on_lsp_attach
  }

  lsp.tsserver.setup { capabilities = capabilities, on_attach = on_lsp_attach }

  lsp.rust_analyzer.setup { capabilities = capabilities, on_attach = on_lsp_attach }

  lsp.vimls.setup { capabilities = capabilities, on_attach = on_lsp_attach }

  lsp.jsonls.setup { capabilities = capabilities, on_attach = on_lsp_attach }


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

  local linters = {
    eslint = {
      sourceName = 'eslint',
      -- TODO: try https://github.com/mantoni/eslint_d.js/
      command = 'eslint',
      rootPatterns = { '.eslintrc.js', 'package.json' },
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
      securities = { [2] = "error", [1] = "warning" }
    }
  }

  local formatters = {
    prettier = { command = "prettier", args = { "--stdin-filepath", "%filepath" } }
  }

  -- see <https://github.com/iamcco/diagnostic-languageserver>
  lsp.diagnosticls.setup {
    filetypes = { 'typescript', 'javascript' },
    init_options = {
      linters = linters,
      filetypes = { typescript = 'eslint', javascript = 'eslint' },
      formatters = formatters,
      formatFiletypes = { typescript = 'prettier' }
    }
  }
end

local function setup_plugins()
  -- TODO: if pluggins missing, abort and tell the user to run lua hi.plugins()

  require('malleatus').setup {}

  vim.g.neoterm_autoinsert = 1

  -- TODO: this can be made more robust (handle origin/main + maybe toggle against upstreams)
  vim.g.gitgutter_diff_base = 'origin/master'
  vim.g.gitgutter_map_keys = 0

  vim.g.nvim_tree_highlight_opened_files = 1 -- highlight open files + folders
  vim.g.nvim_tree_group_empty = 1 -- compact folders that contain only another folder
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

  -- reverse the default ultisnip movement triggers
  vim.g.UltiSnipsJumpForwardTrigger = '<c-k>'
  vim.g.UltiSnipsJumpBackwardTrigger = '<c-j>'

  -- disable automapping from neoterm
  vim.g.neoterm_automap_keys = '😡😡STUPID_PLUGIN_DO_NOT_AUTOMAP'

  -- disable default mappings
  vim.g.bclose_no_default_mapping = true

  local cmp = require 'cmp'
  cmp.setup {
    snippet = { expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end },
    mapping = {
      ['<c-l>'] = cmp.mapping.confirm({ select = true }),
      ['<c-j>'] = cmp.mapping.select_next_item(),
      ['<c-k>'] = cmp.mapping.select_prev_item(),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' }, -- complete symbols (via LSP)
      { name = 'nvim_lsp_signature_help' }, -- signature completion
      { name = 'nvim_lua' }, -- lua nvim api completion (vim.lsp.* &c.)
      { name = 'ultisnips' }, -- UltiSnipsEdit + UltiSnipsAddFileTypes
      -- This is useful when there is no LSP, but with an LSP + snippets it's mostly noise
      -- { name = 'buffer' }, -- autocomplete keywords (&isk) in buffer
      { name = 'path' }, -- trigger via `/`
      { name = 'cmdline' }, { name = 'calc' }, { name = 'emoji' } -- trigger via `:` in insert mode
    })
  }

  -- -- configure /@ search for this buffer's document symbols
  cmp.setup.cmdline('/', {
    sources = cmp.config.sources({ { name = 'nvim_lsp_document_symbol' } }, { { name = 'buffer' } })
  })

  -- see <https://github.com/hrsh7th/nvim-cmp#setup>
  --  can setup per filetype
  --    cmp.setup.filetype('myfiletype', {})
  --  can setup per custom LSP

  local icons = require "nvim-nonicons"

  icons.get("file")

  setup_language_servers()

  -- kick off trouble :: pretty diagnostics
  require 'trouble'.setup {}
  local trouble_provider_telescope = require("trouble.providers.telescope")

  -- see <https://github.com/folke/trouble.nvim/issues/52#issuecomment-863885779>
  -- and <https://github.com/folke/trouble.nvim/issues/52#issuecomment-988874117>
  -- for making trouble work properly with nvim 0.6.x
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  local telescope = require 'telescope'
  telescope.setup {
    defaults = {
      mappings = {
        i = {
          ['<C-k>'] = 'move_selection_previous',
          ['<C-j>'] = 'move_selection_next',
          ['<C-h>'] = 'which_key',
          ['<c-t>'] = trouble_provider_telescope.open_with_trouble
        },
        n = { ['<c-t>'] = trouble_provider_telescope.open_with_trouble }
      }
    },

    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_cursor {}
      }
    },
  }
  telescope.load_extension('ultisnips') -- :Telescope ultisnips snippets search
  telescope.load_extension('fzf') -- use fzf over fzy to get operators
  -- see
  -- <https://github.com/nvim-telescope/telescope-ui-select.nvim#telescope-setup-and-configuration>
  -- for configuring new prompts
  telescope.load_extension('ui-select') -- use telescope for selecting prompt choices

  -- see <https://github.com/nvim-treesitter/nvim-treesitter#modules>
  require 'nvim-treesitter.configs'.setup {
    ensure_installed = 'all',
    highlight = {
      enable = true,

      disable = {
        'lua', -- TS errors in <init.lua>
        'vim', -- more TS errors for e.g. </Users/hjdivad/.local/share/nvim/site/pack/paqs/start/onedark.vim/colors/onedark.vim>
      }
    }
    -- TODO: set up textobjects
    -- see <https://github.com/hjdivad/dotfiles/blob/a22557c32bfb69e574114f6c39b832f7b34da132/home/.config/nvim.symlink/init.vim#L921-L936>
  }

  -- add more aliases here for syntax highlighted code fenced blocks
  vim.g.markdown_fenced_languages = { 'js=javascript', 'ts=typescript' }

  vim.g.vim_markdown_no_extensions_in_markdown = 1 -- assume links like foo mean foo.md
  vim.g.vim_markdown_follow_anchor = 1 -- follow anchors in links like foo.md#wat
  vim.g.vim_markdown_frontmatter = 1 -- highlight YAML frontmatter
  vim.g.vim_markdown_strikethrough = 1 -- add highlighting for ~~strikethrough~~
  vim.g.markdown_auto_insert_bullets = 0 -- don't insert bullets in insert mode; I prefer to use snippets
  vim.g.vim_markdown_new_list_item_indent = 0 -- don't insert bullets in insert mode; I prefer to use snippets

  hjdivad.setup_repls()
  hjdivad.setup_vimtest()
end

local function setup_window_management()
  vim.cmd([[
    augroup WindowManagement
      autocmd!

      " re-arrange windows when vim itself is resized
      autocmd VimResized * wincmd =
    augroup end
  ]])
end

local function create_user_commands()
  vim.api.nvim_create_user_command('HiUpdatePlugins', plugins.update_plugins, { desc = 'Update or install plugins' })
end

local function setup_local_linking()
  vim.opt_global.runtimepath:prepend(vim.env['HOME'] .. '/src/malleatus/common.nvim')
end

local function create_debug_functions()
  ---@diagnostic disable-next-line: lowercase-global
  pp = vim.pretty_print
end

local function main()
  setup_local_linking()
  setup_plugins()
  setup_local_config()
  setup_clipboard()
  setup_colours()
  setup_statusline()
  setup_mappings()
  hjdivad.setup_terminal()
  setup_window_management()
  hjdivad.run_exrc()
  create_user_commands()
end

return {
  main = main,
  update_plugins = plugins.update_plugins,
  create_debug_functions = create_debug_functions,
}
