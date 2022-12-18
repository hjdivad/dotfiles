local M = {}

---Show the nvim-tree
---
---If the tree is not open, open it, otherwise switch to the tree's window.
---
---If the current buffer has a name, also find it in the tree.
---
---*note* finding files works poorly for those outside of `$CWD`
function M.toggle_nvim_tree()
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

local function setup_local_config()
  -- We have to do this before configuring keymaps and we load before any
  -- plugin loads (incl. malleatus)
  vim.g.mapleader = ','
  vim.g.maplocalleader = ','


  -- better diagnostic signs
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  ---spelling
  vim.opt.spelllang = { 'sv', 'en_gb', 'en_us' }
  vim.opt.spellfile = {
    '.vimspell.utf8.add', '~/.local/share/.nvim/spell/en.utf-8.add',
    '~/.local/share/.nvim/spell/sv.utf-8.add'
  }

  -- inform terminals that they are within an nvim instance
  vim.env.NVIM_WRAPPER = 1

  -- TODO: mv to malleatus
  require('hjdivad/exrc').setup {}


  vim.api.nvim_create_user_command('HiDisableMarkdownFolding', function()
    vim.g.vim_markdown_folding_disabled = true
  end, { desc = "Disable Markdown Folding as vim-markdown + treesitter don't get along" })
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

    hi @text.strong guifg=#E5C07B cterm=bold gui=bold       " guifg=Type
    hi @text.emphasis guifg=#C678DD cterm=italic gui=italic " guifg=Question
    hi @text.reference guifg=#6eb1fd
    hi @text.literal guifg=#98c379 ctermfg=114
  ]])
end

local function setup_key_mappings()
  -- @see additional mappings in hjdivad/plugin_config.lua setup_lsp_mappings
  -- those mappings are lazily defined when an LSP attaches

  vim.keymap.del('n', 'Y', {}) -- neovim 0.6.0 maps Y to "$ by default (see default-mappings)

  vim.keymap.set('n', 'Q', '', { desc = 'disable Ex mode from Q (unhelpful fat-finger trap)', })
  vim.keymap.set('n', 'j', 'gj', { desc = 'move (visual) row-wise instead of line-wise', })
  vim.keymap.set('n', 'k', 'gk', { desc = 'move (visual) row-wise instead of line-wise', })
  vim.keymap.set('n', "'", '`', { desc = "`x is more useful, but 'x is easier to type", })


  vim.keymap.set('n', '<leader><leader>', '<cmd>nohl | checktime<cr>', { desc = 'use ,, to clear highlights', })

  vim.keymap.set('n', '<leader>nf', M.toggle_nvim_tree, { desc = 'now files (toggle nvim-tree)', })
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

  vim.keymap.set('n', '<leader>ll', function()
    vim.diagnostic.setqflist({ bufnr = vim.fn.bufnr() })
  end, { desc = 'lint list buffer', })
  vim.keymap.set('n', '<leader>lL', function()
    vim.diagnostic.setqflist()
  end, { desc = 'lint list workspace', })
  vim.keymap.set('n', '<leader>L', function()
    require('lspsaga.diagnostic').show_line_diagnostics()
  end, { desc = 'lint list buffer', })
  vim.keymap.set('n', '<leader>ln', function()
    require('lspsaga.diagnostic').goto_next()
  end, { desc = 'lint next item', })
  vim.keymap.set('n', '<leader>lp', function()
    require('lspsaga.diagnostic').goto_prev()
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
  ---vim.api.nvim_set_keymap('n', '<leader>re', function() require('hjdivad/terminal').edit_repl('yarn repl', 'ts') end)
  ---```
  vim.keymap.set('n', '<leader>re', function()
    require('hjdivad/terminal').edit_generic_repl()
  end, { desc = 'Open a REPL in a terminal and a linked REPL input buffer', })
  vim.keymap.set('v', '<leader>re', ':TREPLSendSelection<cr>', { desc = 'Send selection to the REPL', })

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

  vim.keymap.set('t', '<c-g><c-g>', [[<c-\><c-n>]], { desc = 'Escape terminal with better keymap', })

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

---Creates some functions in the global scope.  Nothing depends on these, they are for user convenience.
---
---* *pp* A synonym for `vim.pretty_print`
function M.create_debug_functions()
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
function M.main(options)
  local opts = vim.tbl_deep_extend('force', {
    plugins = {},
    mappings = false,
  }, options)

  -- TODO: install --headless doesn't install gitgutter & vim-airline
  -- can we install them now?
  if vim.env.UPDATE then
    print('updating plugins')
    require('hjdivad/plugins').update { quit_on_install = true }
    return
  elseif vim.env.ROLLBACK then
    print('rolling back to plugin snapshot')
    require('hjdivad/plugins').rollback { quit_on_install = true }
    return
  else
    local packer_compilation_path = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua'
    if vim.env.INSTALL or (#vim.fn.glob(packer_compilation_path) == 0) then
      -- TODO: this requires nvim installing once if done with --headless --noplugin
      -- but twice if just using nvim, which sucks
      print('no packer compilation found, installing plugins and then quitting.')
      require('hjdivad/plugins').install { quit_on_install = true }
      return
    end
  end

  setup_local_config()
  setup_colours()
  setup_clipboard()
  setup_window_management()

  if opts.mappings then
    setup_key_mappings()
  end
end

return M
