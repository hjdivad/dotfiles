local hjdivad = require 'hjdivad/main'
-- the global namespace, for adding userland hooks like `plugins`
-- as well as entry points for autocommands
local hi = hjdivad.hjdivad_init

local map = hjdivad.map
local nmap = hjdivad.nmap
local nnoremap = hjdivad.nnoremap
local imap = hjdivad.imap
local tnoremap = hjdivad.tnoremap
local nmaptb = hjdivad.nmaptb
local unmap = hjdivad.unmap
local maptb = hjdivad.maptb

local User = vim.fn.expand('$USER')

---use comma as <leader> (default \)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

vim.o.compatible = false -- compatible with what? vi? come on
vim.o.hidden = true -- allow buffer switching without saving
vim.o.history = 10000 -- we can afford a larger history (default 20)
vim.o.updatetime = 100 -- ensure GitGutter and other plugins
vim.o.timeout = true
vim.o.timeoutlen = 1000
vim.o.ttimeoutlen = 50
vim.o.swapfile = false -- don't write swap files
vim.o.mouse = 'a' -- allow resizing windows via the mouse
vim.o.undofile = true -- preserve undo history across sessions
vim.o.lazyredraw = true -- don't redraw during macros
vim.o.shm = 'filnxtToOFsAIc' -- disable some vim messages

---whitespace
vim.o.wrap = true -- wrap lines
vim.o.sidescrolloff = 8 -- left-right context when wrap=false
-- no effect when wrap=true
vim.o.tabstop = 2 -- tab at two spaces
vim.o.shiftwidth = 2 -- autoindent at 2, i.e. match the tabstop
vim.o.smartindent = true -- insert indents automatically
vim.o.expandtab = true -- always use spaces not tabs
vim.o.autoindent = true -- indent in insert mode
vim.o.joinspaces = false -- don't add two spaces after . on join
vim.o.shiftround = true -- always indent to a multiple of shiftwidth

---gutters
vim.o.signcolumn = 'yes' -- always show the sign column
vim.o.number = true -- show line numbers
vim.o.relativenumber = true -- line numbers relative to cursor
vim.o.numberwidth = 3
vim.o.ruler = true -- show line and column number

---windows
vim.o.splitbelow = true -- always split below current window
vim.o.splitright = false -- always split to the right

-- completion
vim.o.wildmode = 'list:longest,full' -- first tab show longest matching substring
-- second tab, complete
vim.o.completeopt = 'menu,noinsert,noselect' -- completion options

-- backspace through everything in insert mode
vim.opt.backspace = {'indent', 'eol', 'start'}

---scrolling
vim.o.cursorline = true -- highlight the line the cursor is on
vim.o.scrolloff = 3 -- minimum lines to keep above and below cursor

---character rendering
vim.o.list = true -- show invisible characters
vim.opt.listchars = {
  tab = '▸ ', -- a tab should display as '▸ ', trailing whitespace as '.'
  trail = '•', -- show trailing spaces as dots
  eol = '¬', -- show eol as '¬'
  extends = '>', -- The character to show in the last column when wrap is
  -- off and the line continues beyond the right of the screen
  precedes = '<', -- The character to show in the last column when wrap is
  nbsp = '.' -- non-breaking space
}
vim.o.conceallevel = 2 -- conceal some text when on a different line, based on synta highlighting

---searching
vim.o.hlsearch = true -- highlight matches
vim.o.incsearch = true -- incremental searching
vim.o.ignorecase = true -- searches are case insensitive...
vim.o.smartcase = true -- ... unless they contain an upper-case character
nnoremap('/', '/\\v') -- make searches very magic by default.  Not Perl regex, but better than regular vim regex

-- when to open folds
vim.opt.foldopen = {
  'block', -- block movement
  'hor', -- horizontal movement
  'insert', -- anything in insert mode
  'jump', -- far jumps (G, gg, &c.)
  'mark', -- jumping to mark
  'percent', -- % (i.e. jump to matching brace)
  'quickfix', -- :cn, :crew, :make &c.
  'tag', -- jumping to a tag (but really who uses tags when you have LSPs)
  'undo' -- open folds when undoing
}

-- TODO: check rg is in path
vim.o.grepprg = 'rg --vimgrep' -- always use rg when you can

---spelling
vim.opt.spelllang = {'sv', 'en_gb', 'en_us'}
vim.opt.spellfile = {
  '.vimspell.utf8.add', '~/.local/share/.nvim/spell/en.utf-8.add',
  '~/.local/share/.nvim/spell/sv.utf-8.add'
}

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
      copy = {['+'] = 'ssh client pbcopy', ['*'] = 'ssh client pbcopy'},
      paste = {['+'] = 'ssh client pbpaste', ['*'] = 'ssh client pbpaste'},
      cache_enabled = true
    }
  end
end

local function setup_colours()
  vim.o.termguicolors = true

  -- see https://github.com/morhetz/gruvbox/wiki/Terminal-specific#1-italics-is-disabled
  -- vim.g.gruvbox_italic = 1
  -- vim.cmd 'silent! colorscheme gruvbox'

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
  -- neovim 0.6.0 maps Y to "$ by default (see default-mappings)
  unmap('n', 'Y')
  nmap('Q', '') -- disable Ex mode from Q
  nmap('j', 'gj') -- move row-wise instead of line-wise
  nmap('k', 'gk') -- move row-wise instead of line-wise
  nmap('<leader><leader>', '<cmd>nohl | checktime<cr>') -- use ,, to clear highlights after a search

  nmap('<leader>nf', '<cmd>lua ha.toggle_nvim_tree()<cr>') -- "now files"
  nmap('<leader>nt', '<cmd>lua ha.toggle_terminal()<cr>') -- "now terminal"

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
  nmaptb('<leader>fr', 'live_grep()') -- grep from pwd
  -- TODO: nice to add a (current_class_fuzzy_find, current_method_fuzzy_find &c.) using treesitter
  -- or perhaps using text objects? fuzzy_find_lines_in_text_objects <af> a function
  nmaptb('<leader>fi', 'current_buffer_fuzzy_find()') -- find (fuzzy) in current buffer
  nmap('<leader>fa', '<cmd>Telescope<cr>', {silent = true}) -- find anything (pick a picker)
  nmaptb('<leader>fh', 'help_tags()') -- find vim help

  nmap('<leader>ll', '<cmd>Trouble document_diagnostics<cr>') -- lint list
  nmap('<leader>lL', '<cmd>Trouble workspace_diagnostics<cr>') -- lint list (more)
  nmap('<leader>ln', [[<cmd>lua require('trouble').next({ skip_groups = true, jump = true })<cr>]]) -- lint next
  nmap('<leader>lp',
       [[<cmd>lua require('trouble').previous({ skip_groups = true, jump = true })<cr>]]) -- lint prev

  -- see https://github.com/nvim-telescope/telescope-symbols.nvim#symbol-source-format
  -- for custom symbols / symbol names
  imap('<C-f>', [[<Cmd>lua require('cmp').complete()<cr>]], {silent = true}) -- manually trigger completion

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
  nmap('<leader>1', '1gt') -- go to tab 1
  nmap('<leader>2', '2gt') -- go to tab 2
  nmap('<leader>3', '3gt') -- go to tab 3
  nmap('<leader>4', '4gt') -- go to tab 4
  nmap('<leader>5', '5gt') -- go to tab 5
  nmap('<leader>6', '6gt') -- go to tab 6
  nmap('<leader>7', '7gt') -- go to tab 7
  nmap('<leader>8', '8gt') -- go to tab 8
  nmap('<leader>9', '9gt') -- go to tab 9
  nmap('<leader>0', '10gt') -- go to tab 10
end

local function setup_lsp_mappings()
  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', {noremap = true})
  map('n', '<c-h>', [[<cmd>lua vim.lsp.buf.signature_help()<cr>]], {silent = true})

  ---telescope variant
  -- maptb('n', '<leader>gd', 'lsp_definitions()') -- go to definition
  -- maptb('n', '<leader>gD', 'lsp_type_definitions()') -- go to type definition
  -- maptb('n', '<leader>gi', 'lsp_implementation()') -- go to implementation
  -- maptb('n', '<leader>gr', 'lsp_references()') -- go to reference(s)

  ---trouble variant
  --- see <https://github.com/folke/trouble.nvim/issues/153>
  -- nmap('<leader>gd', '<cmd>Trouble lsp_definitions<cr>') -- go to definition
  maptb('n', '<leader>gd', 'lsp_definitions()') -- list document symbols
  nmap('<leader>gD', '<cmd>Trouble lsp_type_definitions<cr>') -- go to type definition
  nmap('<leader>gi', '<cmd>Trouble lsp_implementation<cr>') -- go to implementation
  nmap('<leader>gr', '<cmd>Trouble lsp_references<cr>') -- go to reference(s)
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
  maptb('n', '<leader>ca', 'lsp_code_actions()') -- list code actions (under cursor)
  -- TODO: this gets a stacktrace; try again in nvim >= 0.6.2
  -- maptb('v', '<leader>ca', 'lsp_range_code_actions()') -- list code actions (selected)

  nmap('<leader>rn', [[<cmd>lua vim.buf.rename()<cr>]], {silent = true}) -- rename

  imap('<c-h>', [[<cmd>lua vim.lsp.buf.signature_help()<cr>]], {silent = true})
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

  -- setup lua
  local sumneko_root = ''
  local sumneko_binary = ''

  if vim.fn.has('mac') then
    sumneko_root = '/Users/' .. User .. '/src/sumneko/lua-language-server'
    sumneko_binary = sumneko_root .. '/bin/lua-language-server'
  elseif vim.fn.has('unix') then
    sumneko_root = '/home/' .. User .. '/src/sumneko/lua-language-server'
    sumneko_binary = sumneko_root .. '/bin/lua-language-server'
  end

  -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  local lsp = require 'lspconfig'

  lsp.sumneko_lua.setup {
    capabilities = capabilities,
    cmd = {sumneko_binary},
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
          globals = {'vim'}
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

  lsp.tsserver.setup {capabilities = capabilities, on_attach = on_lsp_attach}

  lsp.rust_analyzer.setup {capabilities = capabilities, on_attach = on_lsp_attach}

  lsp.vimls.setup {capabilities = capabilities, on_attach = on_lsp_attach}

  lsp.jsonls.setup {capabilities = capabilities, on_attach = on_lsp_attach}

  local linters = {
    eslint = {
      sourceName = 'eslint',
      -- TODO: try https://github.com/mantoni/eslint_d.js/
      command = 'eslint',
      rootPatterns = {'.eslintrc.js', 'package.json'},
      debounce = 100,
      args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
      parseJson = {
        errorsRoot = "[0].messages",
        line = "line",
        column = "column",
        endLine = "endLine",
        endColumn = "endColumn",
        message = "${message} [${ruleId}]",
        security = "severity"
      },
      securities = {[2] = "error", [1] = "warning"}
    }
  }

  local formatters = {
    prettier = {command = "prettier", args = {"--stdin-filepath", "%filepath"}}
    -- TODO: this formats with the buffer contents *before* save
    -- lua_format = {command = "lua-format", args = {"%filepath"}}
  }

  local formatFiletypes = {typescript = "prettier", lua = "lua_format"}

  -- see <https://github.com/iamcco/diagnostic-languageserver>
  lsp.diagnosticls.setup {
    filetypes = {'typescript', 'javascript', 'lua'},
    init_options = {
      filetypes = {typescript = 'eslint', javascript = 'eslint'},
      linters = linters,
      formatters = formatters,
      formatFiletypes = formatFiletypes
    }
  }
end

local function setup_plugins()
  -- TODO: if pluggins missing, abort and tell the user to run lua hi.plugins()

  vim.g.neoterm_autoinsert = 1

  -- TODO: this can be made more robust (handle origin/main + maybe toggle against upstreams)
  vim.g.gitgutter_diff_base = 'origin/master'
  vim.g.gitgutter_map_keys = 0

  vim.g.nvim_tree_highlight_opened_files = 1 -- highlight open files + folders
  vim.g.nvim_tree_group_empty = 1 -- compact folders that contain only another folder
  require('nvim-tree').setup {
    update_focused_file = {
      enable = true, -- highlight focused file in NVIMTree
      update_cwd = false
    },
    diagnostics = {enable = true, show_on_dirs = true},
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
    snippet = {expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end},
    mapping = {['<c-l>'] = cmp.mapping.confirm({select = true})},
    sources = cmp.config.sources({
      {name = 'nvim_lsp'}, -- complete symbols (via LSP)
      {name = 'nvim_lsp_signature_help'}, -- signature completion
      {name = 'nvim_lua'}, -- lua nvim api completion (vim.lsp.* &c.)
      {name = 'ultisnips'}, -- UltiSnipsEdit + UltiSnipsAddFileTypes
      {name = 'buffer'}, {name = 'path'}, -- trigger via `/`
      {name = 'cmdline'}, {name = 'calc'}, {name = 'emoji'} -- trigger via `:` in insert mode
    })
  }

  -- -- configure /@ search for this buffer's document symbols
  cmp.setup.cmdline('/', {
    sources = cmp.config.sources({{name = 'nvim_lsp_document_symbol'}}, {{name = 'buffer'}})
  })

  -- see <https://github.com/hrsh7th/nvim-cmp#setup>
  --  can setup per filetype
  --    cmp.setup.filetype('myfiletype', {})
  --  can setup per custom LSP

  local icons = require "nvim-nonicons"

  icons.get("file")

  setup_language_servers()

  -- kick off trouble :: pretty diagnostics
  require'trouble'.setup {}
  local trouble_provider_telescope = require("trouble.providers.telescope")

  -- see <https://github.com/folke/trouble.nvim/issues/52#issuecomment-863885779>
  -- and <https://github.com/folke/trouble.nvim/issues/52#issuecomment-988874117>
  -- for making trouble work properly with nvim 0.6.x
  local signs = {Error = " ", Warn = " ", Hint = " ", Info = " "}
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ""})
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
        n = {['<c-t>'] = trouble_provider_telescope.open_with_trouble}
      }
    }
  }
  telescope.load_extension('ultisnips') -- :Telescope ultisnips snippets search
  telescope.load_extension('fzf') -- use fzf over fzy to get operators

  require'nvim-treesitter.configs'.setup {
    ensure_installed = 'maintained',
    highlight = {enable = true}
    -- TODO: set up textobjects
    -- see <https://github.com/hjdivad/dotfiles/blob/a22557c32bfb69e574114f6c39b832f7b34da132/home/.config/nvim.symlink/init.vim#L921-L936>
  }

  -- add more aliases here for syntax highlighted code fenced blocks
  vim.g.markdown_fenced_languages = {'js=javascript', 'ts=typescript'}

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

local function check_or_install_paq()
  local paq_install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  if vim.fn.empty(vim.fn.glob(paq_install_path)) > 0 then
    print('cloning paq-nvim')
    vim.fn.system({
      'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', paq_install_path
    })
  end
end

--- Installs missing plugins and updates existing plugins
function hi.plugins()
  check_or_install_paq()

  local paq = require('paq')

  -- TODO: try out https://github.com/nathom/filetype.nvim
  -- c.f https://github.com/tweekmonster/startuptime.vim
  paq {
    'savq/paq-nvim', -- let paq manage itself
    'tpope/vim-sensible', -- additional defaults beyond nocompatible
    'editorconfig/editorconfig-vim', -- support for editrconfig shared configs beyond vim
    'tpope/vim-fugitive', -- tpope's git integration (blame, navigation &c.)
    'tpope/vim-git', -- git syntax &c.
    'tpope/vim-surround', -- edit inner/outer surroundings (e.g. di" to delete text between quotes)
    'tpope/vim-unimpaired', -- more mappings
    'tpope/vim-repeat', -- make . (repeat) available to plugins
    'tpope/vim-commentary', -- gcc to toggle comment
    'bcaccinolo/bclose', -- Bclose (delete buffer without affecting windows)
    -- TODO: gundo.vim requires python2
    -- 'sjl/gundo.vim'; -- visualize undo tree (requires python2, see :checkhealth)
    'airblade/vim-gitgutter', -- show line-level git diff in the gutter
    'wincent/terminus', -- improved terminal support
    'kassio/neoterm', -- Topen &c.
    'kyazdani42/nvim-tree.lua', -- file explorer
    'vim-airline/vim-airline', -- status line
    'vim-airline/vim-airline-themes', -- status line themes
    'joshdick/onedark.vim', -- colourscheme rob+stef use
    'kyazdani42/nvim-web-devicons', -- add filetype icons
    -- TODO: this doesn't seem to add icons for completion via cmp
    'yamatsum/nvim-nonicons', -- more icons
    'SirVer/ultisnips', -- snippets
    -- native LSP
    'neovim/nvim-lspconfig', -- native lsp
    ---diagnostics
    'folke/lsp-colors.nvim', 'folke/trouble.nvim', -- pretty diagnostics
    ---completion
    'hrsh7th/cmp-nvim-lsp', -- complete by lsp symbols
    'hrsh7th/cmp-buffer', -- complete by keywords in buffer
    'hrsh7th/cmp-path', -- complete file paths
    'hrsh7th/cmp-cmdline', -- /@ searches this buffer's document symbols
    'quangnguyen30192/cmp-nvim-ultisnips', -- complete by UltiSnips snippets
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-emoji', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-calc', -- *very* simple calculations
    'hrsh7th/cmp-nvim-lsp-document-symbol', -- /@ search buffer for LSP document symbols
    'hrsh7th/nvim-cmp', -- TODO: try https://github.com/hrsh7th/cmp-copilot
    --- telescope deps
    'nvim-lua/popup.nvim', -- create floating windows over other windows
    'nvim-lua/plenary.nvim', -- lots of lua utilities
    'sharkdp/fd', -- alternative file finder
    -- TODO: configure telescope
    -- https://github.com/nvim-telescope/telescope.nvim#telescopenvim
    'nvim-telescope/telescope.nvim', -- configurable list fuzzy matcher
    {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
    -- TODO: this work but i prefer cmp-emoji
    -- 'nvim-telescope/telescope-symbols.nvim'; -- telescope emoji search
    'fhill2/telescope-ultisnips.nvim', -- telescope snippets search
    'camgraff/telescope-tmux.nvim', -- telescope tmux search
    -- TODO: try https://github.com/pwntester/octo.nvim
    -- TODO: try https://github.com/nvim-telescope/telescope-github.nvim
    -- TODO: try https://github.com/AckslD/nvim-neoclip.lua
    -- TODO: try https://github.com/sudormrfbin/cheatsheet.nvim
    'nvim-treesitter/nvim-treesitter', -- incremental parsing
    'nvim-treesitter/playground', -- show treesitter parse tree in a buffer
    'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/nvim-treesitter-refactor',

    -- TODO: configure vim-test
    --  see <https://github.com/vim-test/vim-test>
    --  see <https://github.com/hjdivad/dotfiles/blob/a22557c32bfb69e574114f6c39b832f7b34da132/home/.config/nvim.symlink/init.vim#L416-L477>
    'vim-test/vim-test', -- test runner integration
    -- debugging plugins to try
    -- TODO: try https://github.com/mfussenegger/nvim-dap
    --  see <https://github.com/stefanpenner/dotfiles/blob/64df5a20ca0c9b3df0e4ea262b7cb7486e86a9ed/.config/nvim/init.lua#L171-L186>
    -- TODO: https://github.com/rcarriga/nvim-dap-ui
    -- TODO: try https://github.com/nvim-telescope/telescope-dap.nvim
    -- TODO: try https://github.com/puremourning/vimspector
    -- TODO: try https://github.com/nvim-telescope/telescope-vimspector.nvim
    -- TODO: try https://github.com/jvgrootveld/telescope-zoxide
    -- TODO: try https://github.com/ajeetdsouza/zoxide
    -- and try them via tmux display-popup
    'godlygeek/tabular', -- align text :Tabularize /<sep>,<formatstr>
    -- e.g. :Tabularize /,/l1c1r0
    'euclidianAce/BetterLua.vim', -- improved Lua syntax highlighting
    'hjdivad/vim-pdl', -- extremely primitive PDL support
    'gutenye/json5.vim', -- syntax highlighting for json5
    'jparise/vim-graphql', -- syntax highlighting for graphql
    'preservim/vim-markdown', -- better markdown (folds, syntax &c.)
    {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install'} -- preview rendered markdown in browser
    -- TODO: this one doesn't seem great; look for treesitter alternative
    -- 'mustache/vim-mustache-handlebars'; -- .hbs support
  }

  paq.clean() -- :he paq.clean
  paq.update() -- :he paq.update
  paq.install() -- :he paq.install
end

setup_plugins()
setup_clipboard()
setup_colours()
setup_statusline()
setup_mappings()
hjdivad.setup_terminal()
setup_window_management()
hjdivad.run_exrc()

