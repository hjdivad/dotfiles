---Show the nvim-tree
---
---If the tree is not open, open it, otherwise switch to the tree's window.
---
---If the current buffer has a name, also find it in the tree.
---
---*note* finding files works poorly for those outside of `$CWD`
local function toggle_nvim_tree()
  -- TODO: make this work better when opening a file outside of <cwd>, as well as opening a file within <cwd> after nvimtree has cd-d outside
  --  i.e. NVIMTreeOpen dirname (file) or cwd + findfile
  -- TODO: make this work for NEW buffers (i.e buffers never saved)
  local buffer_name = vim.fn.bufname()

  if buffer_name == '' then
    vim.cmd('NvimTreeOpen')
  else
    vim.cmd('NvimTreeFindFile')
  end
end

---Open a REPL terminal that runs `repl_cmd` and begin editing the REPL input buffer `".repl." .. repl_extension`.
---The terminal is placed top-left if any neoterm instances are open, and vertically leftmost otherwise.
---`:write`ing to the RPEL file will send the contents to the repl. The extension is used for file type detection.
---
---@see setup_vimtest()
---@param repl_cmd string a command to start a REPL in a neoterm instance
---@param repl_extension string the name of the file to use for input commands to the REPL
local function edit_repl(repl_cmd, repl_extension)
  local get_neoterm_window_ids = require('hjdivad/terminal').get_neoterm_window_ids
  -- TODO: make a toggle_repl that closes the repl windows if they're open
  local repl_file = '.repl.' .. repl_extension
  if not vim.g.neoterm.repl or not vim.g.neoterm.repl.instance_id then
    local starting_window = vim.api.nvim_get_current_win()
    -- create the REPL buffer
    local open_terminals = get_neoterm_window_ids()
    if #open_terminals > 0 then
      -- TODO: open the terminal if it's not visible
      -- if we have a terminal open on the left, create the REPL buffer in the topleft
      vim.cmd([[
        " Create a new neoterm window in the top-left
        100wincmd h
        100wincmd k
        above new
        Tnew
        normal G
      ]])
    else
      -- if we have no open terminals, create one vertically on the left
      vim.cmd([[
        vertical topleft Tnew
        normal G
      ]])
    end

    -- start the REPL
    vim.cmd([[exe g:neoterm.last_id . 'T ]] .. repl_cmd .. "'")
    -- Set the new neoterm as the REPL terminal
    vim.cmd([[
      exe 'TREPLSetTerm ' . g:neoterm.last_id
    ]])

    -- return to our starting window to edit the repl input file
    vim.api.nvim_set_current_win(starting_window)
  end

  vim.cmd('edit ' .. repl_file)
  vim.cmd('stopinsert')
end

local function edit_generic_repl()
  local repl_cmd = nil
  local repl_extension = nil

  vim.ui.input({ prompt = 'REPL command (e.g. node) > ', default = 'node' },
    function(input) repl_cmd = input end)

  vim.ui.input({ prompt = 'REPL input file extension (e.g. js) > ', default = 'js' },
    function(input) repl_extension = input end)

  if not repl_cmd then error('No REPL command given. Please specify a commnad to start the REPL.') end

  if not repl_extension then
    error(
      'No extension given. Please specify an extension (to trigger filetype) for your REPL input buffer')
  end

  edit_repl(repl_cmd, repl_extension)

  local suggested_keymap = [[vim.api.nvim_set_keymap('n', '<leader>re', function() require('hjdivad').edit_repl(']] .. repl_cmd .. [[', ']] .. repl_extension .. [[') end]]
  vim.notify([[To skip inputs next time, consider adding `]] .. suggested_keymap ..
    [[` to .vimrc.lua]], vim.log.levels.INFO, {})
end

local function setup_repls()
  vim.cmd([[
    augroup REPL
      autocmd!
      autocmd BufWritePre .repl.* exe 'TREPLSendFile'
    augroup end
  ]])
end

local function setup_local_config()
  ---spelling
  vim.opt.spelllang = { 'sv', 'en_gb', 'en_us' }
  vim.opt.spellfile = {
    '.vimspell.utf8.add', '~/.local/share/.nvim/spell/en.utf-8.add',
    '~/.local/share/.nvim/spell/sv.utf-8.add'
  }

  -- inform terminals that they are within an nvim instance
  vim.env.NVIM_WRAPPER = 1
end

local function setup_clipboard()
  vim.o.clipboard = 'unnamed,unnamedplus' -- always yank &c. to clipboard

  local env = vim.env

  -- TODO: detect this in setup and output a log that explains what to do if it's missing
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

--TODO: try heirline see if it's nicer & faster than airline
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

local function setup_key_mappings()
  vim.keymap.del('n', 'Y', {}) -- neovim 0.6.0 maps Y to "$ by default (see default-mappings)

  vim.keymap.set('n', 'Q', '', { desc = 'disable Ex mode from Q (unhelpful fat-finger trap)', })
  vim.keymap.set('n', 'j', 'gj', { desc = 'move (visual) row-wise instead of line-wise', })
  vim.keymap.set('n', 'k', 'gk', { desc = 'move (visual) row-wise instead of line-wise', })
  vim.keymap.set('n', "'", '`', { desc = "`x is more useful, but 'x is easier to type", })


  vim.keymap.set('n', '<leader><leader>', '<cmd>nohl | checktime<cr>', { desc = 'use ,, to clear highlights', })

  vim.keymap.set('n', '<leader>nf', toggle_nvim_tree, { desc = 'now files (toggle nvim-tree)', })
  vim.keymap.set('n', '<leader>nt', function()
    require('hjdivad/terminal').toggle_terminal()
  end, { desc = 'now terminal (intelligent neoterm toggling)', })

  vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end,
    { desc = 'find files relative to `cwd`', })
  vim.keymap.set('n', '<leader>fF',
    function() require('telescope.builtin').find_files({ hidden = true, no_ignore = true }) end,
    { desc = 'find files harder (--hidden --no-ignore)', })
  vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').git_files() end,
    { desc = 'find files in git', })
  -- TODO: improve this; get files from git diff <upstream>
  vim.keymap.set('n', '<leader>fs', function() require('telescope.builtin').git_status() end,
    { desc = 'find files mentioned by git status', })
  vim.keymap.set('n', '<leader>fc', function() require('telescope.builtin').git_commits() end,
    { desc = 'find git commits', })
  vim.keymap.set('n', '<leader>fm', function() require('telescope.builtin').marks() end, { desc = 'find marks', })
  vim.keymap.set('n', '<leader>fb', function() require('telescope.builtin').buffers() end, { desc = 'find buffers', })
  vim.keymap.set('n', '<leader>fr', function() require('telescope.builtin').grep_string({ search = '' }) end,
    { desc = 'ripgrep relative to `cwd`', })
  vim.keymap.set('n', '<leader>fR', function()
    require('telescope.builtin').grep_string({ search = '', additional_args = function() return { '--hidden' } end })
  end, { desc = 'ripgrep harder (--hidden) relative to `cwd`', })
  vim.keymap.set('n', '<leader>FR', function()
    require('telescope.builtin').grep_string({ search = '',
      additional_args = function() return { '--hidden', '--no-ignore' } end })
  end, { desc = 'ripgrep harderest (--hidden --no-ignore) relative to `cwd`', })
  -- TODO: nice to add a (current_class_fuzzy_find, current_method_fuzzy_find &c.) using treesitter
  -- or perhaps using text objects? fuzzy_find_lines_in_text_objects <af> a function
  vim.keymap.set('n', '<leader>fi', function() require('telescope.builtin').current_buffer_fuzzy_find() end,
    { desc = 'fuzzy find lines in buffer', })
  vim.keymap.set('n', '<leader>fa', '<cmd>Telescope<cr>',
    { silent = true, desc = 'find anything by first finding a telescope finder', })
  vim.keymap.set('n', '<leader>fh', function() require('telescope.builtin').help_tags() end,
    { desc = 'find (vim) help tags', })

  vim.keymap.set('n', '<leader>ll', '<cmd>Trouble document_diagnostics<cr>', { desc = 'lint list buffer', })
  vim.keymap.set('n', '<leader>lL', '<cmd>Trouble workspace_diagnostics<cr>', { desc = 'lint list workspace', })
  -- TODO: these two (ln, lp) seem to be broken in nvim 0.7.0
  vim.keymap.set('n', '<leader>ln', function()
    require('trouble').next({ skip_groups = true, jump = true })
  end, { desc = 'lint next item', })
  vim.keymap.set('n', '<leader>lp', function()
    require('trouble').previous({ skip_groups = true, jump = true })
  end, { desc = 'lint previous item', })


  vim.keymap.set('i', '<C-f>', function() require('cmp').complete() end, { desc = 'Manually [re-]trigger completion', })
  vim.keymap.set('n', '<leader>bd', '<cmd>Bclose!<cr><cmd>enew<cr>',
    { desc = 'buffer delete (but retain window, unlike bwipeout!)', })

  vim.keymap.set('n', '<leader>hn', '<cmd>GitGutterNextHunk<cr>', { desc = 'git hunk: next', })
  vim.keymap.set('n', '<leader>hp', '<cmd>GitGutterPrevHunk<cr>', { desc = 'git hunk: previous', })
  vim.keymap.set('n', '<leader>hP', '<cmd>GitGutterPreviewHunk<cr>', { desc = 'git hunk: preview diff', })
  vim.keymap.set('n', '<leader>hu', '<cmd>GitGutterUndoHunk<cr>', { desc = 'git hunk: undo', })

  vim.keymap.set('n', '<leader>ts', '<Cmd>Telescope tmux windows<cr>', { desc = 'tmux: select window', })
  vim.keymap.set('n', '<leader>tt', '<Cmd>silent !tmux switch-client -l<cr>', { desc = 'tmux: toggle previous window', })
  vim.keymap.set('n', '<leader>td', function()
    require('hjdivad/tmux').goto_tmux_session('todos', 'todos')
  end, { desc = 'tmux: todos', })
  vim.keymap.set('n', '<leader>tr', function()
    require('hjdivad/tmux').goto_tmux_session('todos', 'reference')
  end, { desc = 'tmux: reference', })
  vim.keymap.set('n', '<leader>tj', function()
    require('hjdivad/tmux').goto_tmux_session('todos', 'journal')
  end, { desc = 'tmux: journal', })

  ---Mapping for opening up a generic REPL buffer + terminal pair.
  ---In general it's recommended to overwrite this mapping per-project with a
  ---specific repl command and repl file, for example:
  ---```lua
  ---vim.api.nvim_set_keymap('n', '<leader>re', function() require('hjdivad').edit_repl('yarn repl', 'ts') end)
  ---```
  vim.keymap.set('n', '<leader>re', function()
    require('hjdivad').edit_generic_repl()
  end, { desc = 'Open a REPL in a terminal and a linked REPL input buffer', })
  vim.keymap.set('v', '<leader>re', ':TREPLSendSelection', { desc = 'Send selection to the REPL', })

  vim.keymap.set('n', '<leader>rr', '<cmd>TestFile<cr>', { desc = 'Run Test File (vim-test)', })
  vim.keymap.set('n', '<leader>rt', '<cmd>TestNearest<cr>', { desc = 'Run Nearest Test (vim-test)', })
  vim.keymap.set('n', '<leader>rd', function()
    require('hjdivad/testing').debug_nearest()
  end, { desc = 'Debug Nearest Test (vim-test + hjdivad debug transform)', })

  --- yank file [path] to clipboard, using the best register we have available
  local clipboard_reg
  if vim.fn.has('clipboard') then clipboard_reg = '+' else clipboard_reg = '"' end

  vim.keymap.set('n', '<leader>yf', function()
    vim.fn.setreg(clipboard_reg, vim.fn.expand('%'))
  end, { desc = 'yank path to buffer to clipboard', })
  vim.keymap.set('n', '<leader>yF', function()
    vim.fn.setreg(clipboard_reg, vim.fn.expand('%:p'))
  end, { desc = 'yank absolute path to buffer to clipboard', })
  -- yank GitHub permalink to clipboard
  vim.keymap.set('v', '<leader>yg', ':GBrowse!<cr>', { silent = true, desc = 'Yank GitHub permalink to clipboard' })

  ---terminal window mappings & motions
  vim.keymap.set('t', '<c-g><c-g>', [[<c-\><c-n>]], { desc = 'Escape terminal with better keymap', })
  vim.keymap.set('t', '<c-w>h', [[<c-\><c-n><c-w>h]], { desc = 'win-left (in terminal)', })
  vim.keymap.set('t', '<c-w><c-h>', [[<c-\><c-n><c-w>h]], { desc = 'win-left (in terminal)', })
  vim.keymap.set('t', '<c-w>j', [[<c-\><c-n><c-w>j]], { desc = 'win-down (in terminal)', })
  vim.keymap.set('t', '<c-w><c-j>', [[<c-\><c-n><c-w>j]], { desc = 'win-down (in terminal)', })
  vim.keymap.set('t', '<c-w>k', [[<c-\><c-n><c-w>k]], { desc = 'win-up (in terminal)', })
  vim.keymap.set('t', '<c-w><c-k>', [[<c-\><c-n><c-w>k]], { desc = 'win-up (in terminal)', })
  vim.keymap.set('t', '<c-w>l', [[<c-\><c-n><c-w>l]], { desc = 'win-right (in terminal)', })
  vim.keymap.set('t', '<c-w><c-l>', [[<c-\><c-n><c-w>l]], { desc = 'win-right (in terminal)', })
  vim.keymap.set('t', '<c-w>c', [[<c-\><c-n><c-w>c]], { desc = 'win-close (in terminal)', })
  vim.keymap.set('t', '<c-w><c-c>', [[<c-\><c-n><c-w>c]], { desc = 'win-close (in terminal)', })
  -- escape and re-enter insert mode to prevent issue with cursor not appearing in new terminal window
  vim.keymap.set('t', '<c-w>n', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]], { desc = 'win-new (in terminal)', })
  vim.keymap.set('t', '<c-w><c-n>', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]], { desc = 'win-new (in terminal)', })

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
end

local function setup_lsp_mappings()
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show LSP hover (fn docs, help &c.)', })
  vim.keymap.set('n', '<c-h>', vim.lsp.buf.signature_help, { desc = 'Show LSP signature help', })

  -- Trouble's goto definition not working with neovim 0.7.0
  -- vim.keymap.set('n', '<leader>gd', '<cmd>Trouble lsp_definitions<cr>', { desc='go to definition',  })
  vim.keymap.set('n', '<leader>gd', function() require('telescope.builtin').lsp_definitions() end,
    { desc = 'go to definition', })
  vim.keymap.set('n', '<leader>gD', '<cmd>Trouble lsp_type_definitions<cr>', { desc = 'go to type definition', })
  vim.keymap.set('n', '<leader>gi', '<cmd>Trouble lsp_implementation<cr>', { desc = 'go to implementations', })
  vim.keymap.set('n', '<leader>gr', '<cmd>Trouble lsp_references<cr>', { desc = 'go to references', })
  vim.keymap.set('n', '<leader>gt', '<cmd>TroubleToggle<cr>',
    { desc = 'go to/from trouble (i.e. toggle trouble window)', })
  vim.keymap.set('n', '<leader>gci', vim.lsp.buf.incoming_calls, { desc = 'go to calls (inbound) -- who calls me?', })
  vim.keymap.set('n', '<leader>gco', vim.lsp.buf.outgoing_calls, { desc = 'go to calls (outbound) -- who do i call?', })

  vim.keymap.set('n', '<leader>ss', function() require('telescope.builtin').lsp_document_symbols() end,
    { desc = 'show document symbols', })
  vim.keymap.set('n', '<leader>sS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
    { desc = 'show workspace symbols', })
  vim.keymap.set('n', '<leader>SS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
    { desc = 'show workspace symbols', })
  vim.keymap.set('n', '<leader>sf',
    function() require('telescope.builtin').lsp_document_symbols({ symbols = { 'function' } }) end,
    { desc = 'show functions', })
  vim.keymap.set('n', '<leader>so',
    function() require('telescope.builtin').lsp_document_symbols({ symbols = { 'function', 'class' } }) end,
    { desc = 'show outline', })

  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'list code actions under cursor' })
  vim.keymap.set('v', '<leader>ca', vim.lsp.buf.range_code_action, { desc = 'list code actions in range' })

  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'rename symbol under cursor' })

  vim.keymap.set('i', '<c-h>', vim.lsp.buf.signature_help, { desc = 'show signature help' })

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
    if vim.fn.exists('b:formatter_loaded') == 0 then
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

local function setup_plugins(config)
  require('malleatus').setup {}

  -- TODO: move to malleatus
  -- TODO: create a plugin for nvim LSP development
  --    update the vim global for runtime (vim.keymap = vim.keymap or require('vim.keymap'))
  --    update the vim for c api (compile .lua stubs from C, e.g. </Users/hjdivad/src/neovim/neovim/src/nvim/api/vim.c> nvim_set_keymap )
  -- TODO: fill out the vim global for LSP config
  -- TODO: could probably have a single vim = vim or require('vim') doesn't
  -- really help if looping over exports doesn't work and the whole thing has
  -- to be compiled
  if false then
    vim.keymap = require('vim.keymap')
    vim.lsp = require('vim.lsp') -- goto-def doesn't wokr here but it does on keymap?
    vim.fn = require('vim.fn')
    vim.lsp.buf = vim.lsp.buf or require('vim.lsp.buf')
    -- vim.fn.bufname()
    -- vim.lsp.start_client
    -- vim.lsp.buf.rename()
    -- TODO: get this to work for vim.X in shared e.g. vim.tbl_deep_extend
    -- local shared = require('vim.shared')
    -- for name, fn in pairs(shared) do
    --   vim[name] = vim[name] or shared[name]
    -- end
    -- vim['tbl_deep_extend'] = vim['tbl_deep_extend'] or shared.tbl_deep_extend
    -- vim.tbl_deep_extend
  end

  local function check(plugin)
    return config == 'all' or vim.tbl_contains(config, plugin)
  end

  if check('exrc') then
    require('hjdivad/exrc').setup {}
  end

  if check('neoterm') then
    vim.g.neoterm_autoinsert = 1

    -- disable automapping from neoterm
    vim.g.neoterm_automap_keys = '😡😡STUPID_PLUGIN_DO_NOT_AUTOMAP'

    setup_repls()
  end

  if check('gitgutter') then
    -- TODO: this can be made more robust (handle origin/main + maybe toggle against upstreams)
    vim.g.gitgutter_diff_base = 'origin/master'
    vim.g.gitgutter_map_keys = 0
  end


  if check('nvim-tree') then
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


  -- TODO: consider luasnips?
  -- <https://github.com/L3MON4D3/LuaSnip>
  -- examples: <https://github.com/molleweide/LuaSnip-snippets.nvim/tree/main/lua/luasnip_snippets/snippets>
  if check('ultisnips') then
    -- reverse the default ultisnip movement triggers
    vim.g.UltiSnipsJumpForwardTrigger = '<c-k>'
    vim.g.UltiSnipsJumpBackwardTrigger = '<c-j>'
  end

  if check('bclose') then
    -- disable default mappings
    vim.g.bclose_no_default_mapping = true
  end

  if check('cmp') then
    local cmp = require 'cmp'
    cmp.setup {
      snippet = { expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end },
      mapping = {
        ['<c-l>'] = cmp.mapping.confirm({ select = true }),
        ['<c-n>'] = cmp.mapping.select_next_item(),
        ['<c-p>'] = cmp.mapping.select_prev_item(),
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- complete symbols (via LSP)
        { name = 'nvim_lsp_signature_help' }, -- signature completion
        { name = 'nvim_lua' }, -- lua nvim api completion (vim.lsp.* &c.)
        { name = 'ultisnips' }, -- UltiSnipsEdit + UltiSnipsAddFileTypes
        -- This is useful when there is no LSP, but with an LSP + snippets it's mostly noise
        -- { name = 'buffer' }, -- autocomplete keywords (&isk) in buffer
        { name = 'path' }, -- trigger via `/`
        { name = 'emoji' }, -- trigger via `:` in insert mode
        -- TODO: this doesn't seem to be working
        { name = 'cmdline' },
      })
    }

    -- TODO: this doesn't seem to be working
    -- <https://github.com/hrsh7th/cmp-cmdline>
    cmp.setup.cmdline(':', {
      sources = { name = 'cmdline' }
    })

    -- see <https://github.com/hrsh7th/nvim-cmp#setup>
    --  can setup per filetype
    --    cmp.setup.filetype('myfiletype', {})
    --  can setup per custom LSP

  end

  if check('nvim-nonicons') then
    local icons = require('nvim-nonicons')

    icons.get('file')
  end

  if check('lspconfig') then
    setup_language_servers()
  end

  if check('telescope') then
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
  end

  -- Don't try to run treesitter in CI, installation slows things down enough
  -- to interfere with tests.
  if check('nvim-treesitter') and vim.env.CI ~= 'true' then

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

    -- see <https://github.com/nvim-treesitter/nvim-treesitter#modules>
  end

  if check('vim-markdown') then
    -- add more aliases here for syntax highlighted code fenced blocks
    vim.g.markdown_fenced_languages = { 'js=javascript', 'ts=typescript' }

    vim.g.vim_markdown_no_extensions_in_markdown = 1 -- assume links like foo mean foo.md
    vim.g.vim_markdown_follow_anchor = 1 -- follow anchors in links like foo.md#wat
    vim.g.vim_markdown_frontmatter = 1 -- highlight YAML frontmatter
    vim.g.vim_markdown_strikethrough = 1 -- add highlighting for ~~strikethrough~~
    vim.g.markdown_auto_insert_bullets = 0 -- don't insert bullets in insert mode; I prefer to use snippets
    vim.g.vim_markdown_new_list_item_indent = 0 -- don't insert bullets in insert mode; I prefer to use snippets
  end

  if check('vim-test') then
    require('hjdivad/testing').setup_vimtest()
  end
end

-- TODO: purify
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
  vim.api.nvim_create_user_command('HiUpdatePlugins', function()
    require('hjdivad/plugins').update_plugins {}
  end, { desc = 'Update or install plugins' })

  vim.api.nvim_create_user_command('HiResize', function()
    require('hjdivad/terminal').resize_with_terminal()
  end, { desc = 'Resize windows, ensuring a fixed-width terminal has appropriate width' })

  vim.api.nvim_create_user_command('HiDisableMarkdownFolding', function()
    vim.g.vim_markdown_folding_disabled = true
  end, { desc = "Disable Markdown Folding as vim-markdown + treesitter don't get along" })
end

---Creates some functions in the global scope.  Nothing depends on these, they are for user convenience.
---
---* *pp* A synonym for `vim.pretty_print`
local function create_debug_functions()
  ---@diagnostic disable-next-line: lowercase-global
  pp = vim.pretty_print
end

---@class MainConfig
---@field plugins string|table
---@field mappings boolean

--- Configure neovim.
---
---@param options MainConfig Configuration options.
--- * *plugins* What plugins to configure. Can be `'all'` or a list of plugin names. Defaults to `{}`.
--- * *mappings* Whether to create keymappings. Defaults to `false`.
local function main(options)
  --TODO: bootstrap here

  local opts = vim.tbl_deep_extend('force', {
    plugins = {},
    mappings = false,
  }, options)

  setup_local_config()
  setup_colours()

  -- TODO: move these to malleatus?
  setup_plugins(opts.plugins)
  setup_clipboard()
  setup_window_management()
  setup_statusline()
  require('hjdivad/terminal').setup_terminal()
  create_user_commands()

  if opts.mappings then
    setup_key_mappings()
  end
end

return {
  -- lib entry points

  edit_repl = edit_repl,
  edit_generic_repl = edit_generic_repl,
  toggle_nvim_tree = toggle_nvim_tree,

  -- main entry points

  main = main,
  create_debug_functions = create_debug_functions,
}