-- TODO: instead of having a separate bootstrap file, just have init.lua
-- auto-install (but not auto-update), at least once or something.

-- seehttps://github.com/neovim/neovim/issues/12432#issuecomment-691616755
vim.o.display = 'lastline'
require('hjdivad/plugins').update_plugins({ quit_on_install = true })

-- require 'nvim-treesitter.configs'.setup {
--   ensure_installed = 'all',
--   sync_install = true,
-- }
