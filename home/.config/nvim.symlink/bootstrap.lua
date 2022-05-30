-- TODO: instead of having a separate bootstrap file, just have init.lua
-- auto-install (but not auto-update), at least once or something.

vim.api.nvim_create_autocmd('User', { pattern = 'PaqDoneInstall', once = true, command = 'quit' })
require('hjdivad/plugins').update_plugins()

-- require 'nvim-treesitter.configs'.setup {
--   ensure_installed = 'all',
--   sync_install = true,
-- }
