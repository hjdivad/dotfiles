if not type(vim.fn.UltiSnipsAddFileTypes) == 'function' then
  -- ultisnips not loaded, bail
  return
end

local filename = vim.fn['expand']('%:t')
if filename:find('_spec.lua$') then
  vim.cmd('UltiSnipsAddFiletypes plenary')

  -- vim-test doesn't support Plenary
  vim.keymap.set('n', '<leader>rt', function()
    local cwd = vim.fn.getcwd()
    vim.api.nvim_set_current_dir('home/.config/nvim.symlink')
    require('plenary.test_harness').test_directory(vim.fn.expand('%:p'), { minimal_init = 'tests/test_init.vim' })
    vim.api.nvim_set_current_dir(cwd)
  end, { desc = "Run the current file's tests in Plenary", buffer = true })
end

vim.fn['UltiSnips#AddFiletypes']('nvim')
