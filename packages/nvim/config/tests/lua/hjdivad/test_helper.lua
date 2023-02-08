local Log = require('plenary.log')
local say = require('say')
local async_util = require('plenary/async/util')
local async = require('plenary/async')

local level = vim.fn.getenv('DEBUG')
if level == vim.NIL then
  level = 'info'
end

local M = {}

M.log = Log.new {
  plugin = 'hjdivad_init_test',
  level = level,
  -- TODO: this does write to $HOME/.cache/nvim/hjdivad_init.log
  -- but does not seem to write to the console at all
  use_console = 'sync',
}
local log = M.log


local function matches(_, args)
  local pattern = args[1]
  local string = args[2]
  return string and string:find(pattern) ~= nil
end

local function keymaps_has(keymaps, raw_lhs)
  -- mapping <c-w>x will be saved as <C-W>x
  local lhs = raw_lhs:gsub('(<[^>]*>)', function(match)
    return match:upper()
  end)

  for _, keymap in ipairs(keymaps) do
    -- An improvement would be to auto-uppercase strings like <c-w>
    if lhs == keymap.lhs then
      return true
    end
  end

  return false
end

function M.find_winid_top_left()
  local win_ids = vim.api.nvim_list_wins()
  local min_top = 999
  local top_row
  for _, win_id in ipairs(win_ids) do
    local top, left = unpack(vim.api.nvim_win_get_position(win_id))
    if top < min_top then
      min_top = top
      top_row = {}
    end

    if top == min_top then
      table.insert(top_row, { win_id, left })
    end
  end

  local min_left = 999
  local far_left_win
  for _, top_row_win in ipairs(top_row) do
    local win_id, left = unpack(top_row_win)
    if left < min_left then
      min_left = left
      far_left_win = win_id
    end
  end

  return far_left_win
end

local function has_keymap(_, args)
  local mode = args[1]
  local raw_lhs = args[2]


  return keymaps_has(vim.api.nvim_get_keymap(mode), raw_lhs)
end

local function buf_has_keymap(_, args)
  local bufnr = args[1]
  local mode = args[2]
  local raw_lhs = args[3]

  return keymaps_has(vim.api.nvim_buf_get_keymap(bufnr, mode), raw_lhs)
end

local assertions_setup = false

function M.setup()
  if assertions_setup then
    return
  end

  -- these get formatted in a bad way, probably due to
  -- https://github.com/Olivine-Labs/luassert/blob/e2ab0d218d7a63bbaa2fdebfa861c24a48451e9d/src/assert.lua#L17
  say:set('assertion.matches.positive', 'Expected pattern %s to match string %s')
  say:set('assertion.matches.negative', 'Expected pattern %s to not match string %s')
  assert:register('assertion', 'matches', matches, 'assertion.matches.positive', 'assertion.matches.negative')

  say:set('assertion.has_keymap.positive', 'Expected mode %s to have keymap %s')
  say:set('assertion.has_keymap.negative', 'Expected mode %s to not have keymap %s')
  assert:register('assertion', 'has_keymap', has_keymap, 'assertion.has_keymap.positive', 'assertion.has_keymap.negative')

  say:set('assertion.buf_has_keymap.positive', 'Expected buffer %s mode %s to have keymap %s')
  say:set('assertion.buf_has_keymap.negative', 'Expected buffer %s mode %s to not have keymap %s')
  -- luaassert has some kind of DSL that prevents naming this buf_has_keymap
  assert:register('assertion', 'has_buf_keymap', buf_has_keymap, 'assertion.buf_has_keymap.positive',
    'assertion.buf_has_keymap.negative')

  assertions_setup = true
end

function M.health_check()
  assert.equal(1, #vim.api.nvim_list_wins(), 'no windows left open')
  assert.equal(1, #vim.api.nvim_list_bufs(), 'no buffers left open')
  assert.matches('^$', vim.fn.bufname(), 'start on [no name] buffer')
end

function M.teardown()
  -- close any windows the test opened
  for _ = 2, #vim.api.nvim_list_wins(), 1 do
    vim.cmd('wincmd c')
  end

  -- delete all buffers, except a single new empty buffer
  local bufs = vim.api.nvim_list_bufs()
  vim.cmd('enew')

  for _, buf_id in ipairs(bufs) do
    vim.api.nvim_buf_delete(buf_id, { force = true })
  end
end

local function wait_next_tick()
  local err = async_util.scheduler()
  assert.equals(nil, err, 'vim.schedule callback without error')
end

local wait_ms = async.wrap(function(t, cb)
  vim.defer_fn(cb, t)
end, 2)

---TODO: docme
---Wait until the next tick in the main loop using `vim.schedule`.
---
---*note* Probably does not guarantee order. If you see race conditions,
---consider using `vim.wait` (wrapped via `plenary/async.wrap`) instead.
function M.wait(t)
  if t then
    wait_ms(t)
  else
    wait_next_tick()
  end
end

function M.find_winnr_with_buffer_name(search_bufname)
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

function M.find_bufnr_with_buffer_name(search_bufname)
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

return M
