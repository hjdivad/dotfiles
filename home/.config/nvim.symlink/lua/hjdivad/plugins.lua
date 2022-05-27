local function check_or_install_paq()
  local paq_install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  if vim.fn.empty(vim.fn.glob(paq_install_path)) > 0 then
    print('cloning paq-nvim')
    print(vim.fn.system({
      'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', paq_install_path
    }))
  end
end

--- Installs missing plugins and updates existing plugins
local function update_plugins()
  check_or_install_paq()

  local paq = require('paq')

  -- c.f https://github.com/tweekmonster/startuptime.vim
  paq {
    'savq/paq-nvim', -- let paq manage itself

    'malleatus/common.nvim', -- common dotfiles

    'tpope/vim-sensible', -- additional defaults beyond nocompatible
    'editorconfig/editorconfig-vim', -- support for editrconfig shared configs beyond vim
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
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    -- TODO: this work but i prefer cmp-emoji
    -- 'nvim-telescope/telescope-symbols.nvim'; -- telescope emoji search
    'nvim-telescope/telescope-ui-select.nvim', -- use telescope to select choices
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
    'preservim/vim-markdown', -- i use this for folding only
    { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' } -- preview rendered markdown in browser
    -- TODO: this one doesn't seem great; look for treesitter alternative
    -- 'mustache/vim-mustache-handlebars'; -- .hbs support
  }

  paq.clean() -- :he paq.clean
  paq.update() -- :he paq.update
  paq.install() -- :he paq.install
end

return {
  update_plugins = update_plugins,
}
