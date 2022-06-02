local Log = require('plenary.log')
local say = require('say')
local async_util = require('plenary/async/util')

local level = vim.fn.getenv('DEBUG')
if level == vim.NIL then
  level = 'info'
end
local log = Log.new {
  plugin = 'hjdivad_init',
  level = level,
  -- TODO: this does write to $HOME/.cache/nvim/hjdivad_init.log
  -- but does not seem to write to the console at all
  use_console = 'sync',
}

local function matches(_, args)
  local pattern = args[1]
  local string = args[2]
  return string:find(pattern) ~= nil
end

local assertions_setup = false

local function setup()
  if assertions_setup then
    return
  end

  -- these get formatted in a bad way, probably due to
  -- https://github.com/Olivine-Labs/luassert/blob/e2ab0d218d7a63bbaa2fdebfa861c24a48451e9d/src/assert.lua#L17
  say:set('assertion.matches.positive', 'Expected pattern %s to match string %s')
  say:set('assertion.matches.negative', 'Expected pattern %s to not match string %s')
  assert:register('assertion', 'matches', matches, 'assertion.matches.positive', 'assertion.matches.negative')

  assertions_setup = true
end

---Wait until the next tick in the main loop using `vim.schedule`.
---
---*note* Probably does not guarantee order. If you see race conditions,
---consider using `vim.wait` (wrapped via `plenary/async.wrap`) instead.
local function wait()
  local err = async_util.scheduler()
  assert.equals(nil, err, 'vim.schedule callback without error')
end

local function find_winnr_with_buffer_name(search_bufname)
  local wins = vim.api.nvim_list_wins()
  for _, winnr in ipairs(wins) do
    local bufnr = vim.fn.winbufnr(winnr)
    local bufname = vim.fn.bufname(bufnr)
    if search_bufname == bufname then
      return winnr
    end
  end

  return nil
end

local function find_bufnr_with_buffer_name(search_bufname)
  local buffers = vim.api.nvim_list_bufs()
  log.trace('find_bufnr: search', search_bufname)
  for _, bufnr in ipairs(buffers) do
    local bufname = vim.fn.bufname(bufnr)
    if search_bufname == bufname then
      return bufnr
    end
  end

  return nil
end

return {
  wait = wait,
  log = log,
  setup = setup,
  find_winnr_with_buffer_name = find_winnr_with_buffer_name,
  find_bufnr_with_buffer_name = find_bufnr_with_buffer_name,
}
