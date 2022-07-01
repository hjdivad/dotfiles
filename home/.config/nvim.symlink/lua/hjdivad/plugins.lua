local function check_or_install_paq()
  local paq_install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  if vim.fn.empty(vim.fn.glob(paq_install_path)) > 0 then
    print('cloning paq-nvim')
    print(vim.fn.system({
      'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', paq_install_path
    }))
    print('paq installed')

    if vim.fn.empty(vim.fn.glob(paq_install_path)) > 0 then
      error('Failed to install paq to "' .. paq_install_path .. '"')
    end

    vim.cmd('packadd paq-nvim')
  else
    print('paq already installed')
  end
end

--- Installs missing plugins and updates existing plugins
local function update_plugins(opts)
  check_or_install_paq()

  print('Configuring upstream packages')
  local paq = require('paq')

  paq {
    'savq/paq-nvim',
    'nvim-treesitter/nvim-treesitter',
    'kyazdani42/nvim-web-devicons',
  }

  print('Installing post-uptsream event handler')
  local downstream_install
  downstream_install = vim.api.nvim_create_autocmd('User', {
    pattern = 'PaqDoneInstall',
    callback = function()
      print('Upstream packages installed.')
      print('Loading upstream packages.')
      vim.cmd([[
        packadd nvim-treesitter
        packadd nvim-web-devicons
      ]])
      vim.api.nvim_del_autocmd(downstream_install)

      if opts.quit_on_install then
        print('Installing quit on install autocmd')
        vim.api.nvim_create_autocmd('User', { pattern = 'PaqDoneInstall', once = true, command = 'quit' })
      end

      local plugins = {
        'savq/paq-nvim', -- let paq manage itself

        'malleatus/common.nvim', -- common dotfiles

        'tpope/vim-sensible', -- additional defaults beyond nocompatible
        'tpope/vim-fugitive', -- tpope's git integration (blame, navigation &c.)
        'tpope/vim-rhubarb', -- make fugitive's GBrowse work
        'tpope/vim-git', -- git syntax &c.
        'tpope/vim-surround', -- edit inner/outer surroundings (e.g. di" to delete text between quotes)
        'tpope/vim-unimpaired', -- more mappings
        'tpope/vim-repeat', -- make . (repeat) available to plugins
        'tpope/vim-commentary', -- gcc to toggle comment
        'bcaccinolo/bclose', -- Bclose (delete buffer without affecting windows)
        -- TODO: gundo.vim requires python2
        -- 'sjl/gundo.vim'; -- visualize undo tree (requires python2, see :checkhealth)

        ---Terminal
        'wincent/terminus', -- improved terminal support
        'kassio/neoterm', -- Topen &c.
        'kyazdani42/nvim-tree.lua', -- file explorer

        ---Colourscheme & Icons
        'joshdick/onedark.vim', -- colourscheme rob+stef use
        'kyazdani42/nvim-web-devicons', -- add filetype icons
        -- TODO: this doesn't seem to add icons for completion via cmp
        'yamatsum/nvim-nonicons', -- more icons
        'folke/lsp-colors.nvim', -- add LSP diagnostic highlights

        -- LSP
        'neovim/nvim-lspconfig', -- native lsp

        ---diagnostics, formatting &c.
        'kevinhwang91/nvim-bqf', -- better quickfix
        'editorconfig/editorconfig-vim', -- support for editrconfig shared configs beyond vim

        ---completion & snippets
        'SirVer/ultisnips', -- snippets
        'hrsh7th/nvim-cmp', -- TODO: try https://github.com/hrsh7th/cmp-copilot
        'hrsh7th/cmp-nvim-lsp', -- complete by lsp symbols
        'hrsh7th/cmp-path', -- complete file paths
        'hrsh7th/cmp-cmdline', -- /@ searches this buffer's document symbols
        'quangnguyen30192/cmp-nvim-ultisnips', -- complete by UltiSnips snippets
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-emoji', --complete emoji
        'hrsh7th/cmp-nvim-lua', --complete neovim's runtime api `vim.lsp.*` &c.
        'hrsh7th/cmp-nvim-lsp-document-symbol', -- /@ search buffer for LSP document symbols

        --- telescope deps
        'nvim-lua/popup.nvim', -- create floating windows over other windows
        'nvim-lua/plenary.nvim', -- lots of lua utilities
        'sharkdp/fd', -- alternative file finder
        'nvim-telescope/telescope.nvim', -- configurable list fuzzy matcher
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        'nvim-telescope/telescope-ui-select.nvim', -- use telescope to select choices
        'fhill2/telescope-ultisnips.nvim', -- telescope snippets search
        'camgraff/telescope-tmux.nvim', -- telescope tmux search
        -- TODO: try https://github.com/pwntester/octo.nvim
        -- TODO: try https://github.com/nvim-telescope/telescope-github.nvim
        -- TODO: try https://github.com/AckslD/nvim-neoclip.lua
        -- TODO: try https://github.com/sudormrfbin/cheatsheet.nvim
        'nvim-treesitter/nvim-treesitter', -- incremental parsing
        'nvim-treesitter/playground', -- show treesitter parse tree in a buffer
        'nvim-treesitter/nvim-treesitter-textobjects', -- create user-textobjects using treesitter

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
        'preservim/vim-markdown', -- i use this for folding only
        -- TODO: this one doesn't seem great; look for treesitter alternative
        -- 'mustache/vim-mustache-handlebars'; -- .hbs support
        -- TODO: try 'gh.nvim'
      }

      local plugins_requiring_ui = {
        { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' }, -- preview rendered markdown in browser
        { 'vim-airline/vim-airline' }, -- status line
        { 'vim-airline/vim-airline-themes' }, -- status lines themes
        { 'airblade/vim-gitgutter' }, -- show line-level git diff in the gutter
      }

      if #vim.api.nvim_list_uis() > 0 then
        for _, plugin_config in ipairs(plugins_requiring_ui) do
          plugins[#plugins + 1] = plugin_config
        end
      end

      paq(plugins)

      print('Installing downstream packages')
      paq.clean() -- :he paq.clean
      paq.update() -- :he paq.update
      paq.install() -- :he paq.install
    end
  })

  print('Installing upstream packages')
  paq.install() -- :he paq.install
end

return {
  -- TODO: try https://github.com/wbthomason/packer.nvim ?
  update_plugins = update_plugins,
}
