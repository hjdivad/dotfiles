local M = {};

local is_headless = #vim.api.nvim_list_uis() == 0

local function check_or_install_packer()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    print('cloning packer.nvim')
    local bootstrap = vim.fn.system({
      'git', 'clone', '--depth=1', 'https://github.com/wbthomason/packer.nvim', install_path
    })
    print(bootstrap)

    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
      error('Failed to install packer to "' .. install_path .. '"')
    end

    vim.cmd [[packadd packer.nvim]]
  end
end

check_or_install_packer()

local packer = require 'packer'
local util = require 'packer.util'
local snapshot_path = util.join_paths(vim.fn.stdpath('config'), 'plugins-dev-snapshot.json')

-- TODO: move to plugin_config
packer.startup({
  require('hjdivad/plugin_config'),
  config = {
    -- uncomment to change packer's log level
    -- log = { level = 'debug' },
    git = {
      subcommands = {
        -- use --force because kyazdani42/nvim-tree.lua uses a "nightly" tag
        update = 'pull --force --ff-only --progress --rebase=false'
      }
    }
  }
})

function M.take_snapshot(opts)
  opts = opts or { quit_on_install = is_headless }

  -- delete the existing snapshot so that we can write the new one without prompting
  vim.fn.system('rm ' .. snapshot_path)
  packer.snapshot(snapshot_path)

  vim.defer_fn(function()
    local cleanup_script_path = util.join_paths(vim.fn.stdpath('config'), 'scripts', 'cleanup-plugins-snapshot.js')

    vim.fn.system('node ' .. cleanup_script_path .. ' ' .. snapshot_path);

    if opts.quit_on_install then
      vim.cmd('quitall')
    end
  end, 5000)
end

local function install_compile_after_PackerComplete_hook(from, opts)
  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'PackerComplete',
    callback = function()
      print('initial ' .. from .. ' complete, running `packer.clean()` to remove any unspecified dependencies')
      packer.clean()

      vim.api.nvim_create_autocmd('User', {
        once = true,
        pattern = 'PackerComplete',
        callback = function()
          vim.api.nvim_create_autocmd('User', {
            once = true,
            pattern = 'PackerCompileDone',
            callback = function()
              print('`packer.compile()` complete');

              if (opts.quit_on_install) then
                vim.cmd('quitall')
              end
            end
          })

          print('`packer.clean()` completed, running `packer.compile()` now')
          -- once installed, compile the plugins/packer_compiled.lua file
          packer.compile();
        end
      })
    end
  })
end

function M.update(options)
  local opts = vim.tbl_deep_extend('force', {
    quit_on_install = is_headless
  }, options or {})

  -- autocmd User PackerComplete quitall
  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'PackerComplete',
    callback = function()
      M.take_snapshot(opts)
    end,
  })

  print('running `packer.sync()`')
  packer.sync() -- Perform `PackerUpdate` and then `PackerCompile`
end

function M.install(options)
  local opts = vim.tbl_deep_extend('force', {
    quit_on_install = is_headless
  }, options or {})

  -- autocmd User PackerComplete quitall
  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'PackerComplete',
    callback = function()
      M.take_snapshot(opts)
    end,
  })

  -- setup the hook to run packer.compile(), but ensure it doesn't quit early
  -- since that should be done by `take_snapshot`
  install_compile_after_PackerComplete_hook('install', { quit_on_install = false })

  print('running `packer.install()`')
  packer.install() -- Perform `PackerUpdate` and then `PackerCompile`
end

function M.rollback(options)
  local opts = vim.tbl_deep_extend('force', {
    quit_on_install = is_headless
  }, options or {})

  install_compile_after_PackerComplete_hook('rollback', opts)

  -- install from plugins-dev.json lockfile
  print('rolling plugin config back to ' .. snapshot_path)
  packer.rollback(snapshot_path)
end

M.bootstrap = M.rollback;

return M
