-- TODO: instead of having a separate bootstrap file, just have init.lua
-- auto-install (but not auto-update), at least once or something.
require('hjdivad/plugins').update_plugins()

require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'all',
}
vim.cmd('TSInstallSync all')
