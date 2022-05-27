local main = require('hjdivad/main')
local init = require('hjdivad_init')
local ptest = require('plenary/async/tests')
local async_util = require('plenary/async/util')
local say = require('say')
local level = vim.fn.getenv('DEBUG')
-- TODO: extract these utilities to a test util
if level == vim.NIL then
  level = 'info'
end
local log = require('plenary.log').new {
  plugin = 'hjdivad_init',
  level = level,
  -- TODO: this does write to $HOME/.cache/nvim/hjdivad_init.log
  -- but does not seem to write to the console at all
  use_console = 'sync',
}
local a = {
  describe = ptest.describe,
  it = ptest.it,
  before_each = ptest.before_each,
  after_each = ptest.after_each,
}

---Wait until the next tick in the main loop using `vim.schedule`.
---
---*note* Probably does not guarantee order. If you see race conditions,
---consider using `vim.wait` (wrapped via `plenary/async.wrap`) instead.
local function wait()
  local err = async_util.scheduler()
  assert.equals(nil, err, 'vim.schedule callback without error')
end

local function matches(_, args)
  local pattern = args[1]
  local string = args[2]
  return string:find(pattern) ~= nil
end

-- these get formatted in a bad way, probably due to
-- https://github.com/Olivine-Labs/luassert/blob/e2ab0d218d7a63bbaa2fdebfa861c24a48451e9d/src/assert.lua#L17
say:set('assertion.matches.positive', 'Expected pattern %s to match string %s')
say:set('assertion.matches.negative', 'Expected pattern %s to not match string %s')
assert:register('assertion', 'matches', matches, 'assertion.matches.positive', 'assertion.matches.negative')

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

a.describe('main.toggle_nvim_tree', function()
  -- TODO: this is overkill just for loading nvim-tree
  -- maybe expose _setup_plugins for testing
  init.main()

  a.after_each(function()
    vim.cmd('NvimTreeClose')
  end)

  a.it("opens the nvim tree when it's not visible", function()
    -- initially no nvim tree open
    assert.equals(nil, find_winnr_with_buffer_name('NvimTree_1'), 'nvim tree is closed')

    main.toggle_nvim_tree()

    local nvim_tree_winnr = find_winnr_with_buffer_name('NvimTree_1')
    assert.equals(true, nvim_tree_winnr ~= nil, 'nvim tree is open')
    assert.equals(vim.api.nvim_get_current_win(), nvim_tree_winnr, 'nvim tree is focused')
  end)

  a.it("Searches for the buffer's file in the tree", function()
    vim.cmd('edit tests/hjdivad/main_spec.lua')
    main.toggle_nvim_tree()
    wait()

    local nvim_tree_bufnr = find_bufnr_with_buffer_name('NvimTree_1')

    assert.is_not.Nil(nvim_tree_bufnr, 'nvim tree is open')

    local linenr = vim.fn.getcursorcharpos()[2]
    local line = vim.fn.getbufline(nvim_tree_bufnr, linenr)[1]

    assert.matches('.*%smain_spec%.lua', line, 'nvim tree is open at the buffer')
  end)

end)
