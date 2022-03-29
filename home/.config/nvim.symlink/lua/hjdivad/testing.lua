local utils = require('hjdivad.utils')
local ha = utils.hjdivad_auto

function ha.vimtest_debug_transform(raw_cmd)
  local cmd = raw_cmd
  local env_extra = {}

  if vim.t.test_debugging then
    local debugging = false

    if cmd:find('node', 1, true) then
      table.insert(env_extra, 'NODE_OPTIONS="--inspect-brk"')
      debugging = true
    end

    if cmd:find('jest', 1, true) then
      local cmd_parts = vim.split(cmd, ' -- ', {plain = true})
      cmd = cmd_parts[#cmd_parts - 1] .. '--testTimeout=0 --runInBand' .. cmd_parts[#cmd_parts]
    end

    if not debugging then
      error([[Don't know how to debug cmd: "]] .. cmd .. '"\n' ..
              [[Expecting cmd to contain 'node']])
    end
  end

  if vim.t.env_extra then table.insert(env_extra, vim.t.env_extra) end

  if #env_extra > 0 then cmd = 'env ' .. table.concat(env_extra, ' ') .. ' ' .. cmd end
  return cmd
end

function ha.debug_nearest()
  vim.t.test_debugging = true
  vim.cmd('TestNearest')
  vim.t.test_debugging = false
end

local function setup_vimtest()
  vim.g['test#strategy'] = 'neoterm'
  vim.cmd([[
    function! HjdivadDebugTransform(cmd) abort
      return luaeval('ha.vimtest_debug_transform(_A)', a:cmd)
    endfunction
    let g:test#custom_transformations = { 'debug': function('HjdivadDebugTransform') }
  ]])
  vim.g['test#transformation'] = 'debug'
end

return {setup_vimtest = setup_vimtest}
