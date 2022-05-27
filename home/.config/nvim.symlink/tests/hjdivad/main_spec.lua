local main = require('hjdivad/main')
local ptest = require('plenary/async/tests')
local async_util = require('plenary/async/util')
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
  for _, bufnr in ipairs(buffers) do
    local bufname = vim.fn.bufname(bufnr)
    if search_bufname == bufname then
      return bufnr
    end
  end

  return nil
end

a.describe('main.toggle_nvim_tree', function()
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
    vim.cmd('edit home/.config/nvim.symlink/tests/hjdivad/main_spec.lua')
    main.toggle_nvim_tree()

    wait()

    local nvim_tree_bufnr = find_bufnr_with_buffer_name('NvimTree_1')

    assert.equals(true, nvim_tree_bufnr ~= nil, 'nvim tree is open')

    local linenr = vim.fn.getcursorcharpos()[2]
    local line = vim.fn.getbufline(nvim_tree_bufnr, linenr)[1]

    assert.is_not.Nil(line and line:find('.*%smain_spec%.lua'), 'nvim tree is open at the buffer')
  end)

end)
