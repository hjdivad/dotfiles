local ptest = require('plenary/async/tests')

local test_helper = require('hjdivad/test_helper')

local init = require('hjdivad')


local find_winnr_with_buffer_name = test_helper.find_winnr_with_buffer_name
local find_bufnr_with_buffer_name = test_helper.find_bufnr_with_buffer_name
local wait = test_helper.wait

local function find_mapping(mode, lhs)
  local mode_mappings = vim.api.nvim_get_keymap(mode)
  for _, mapping in ipairs(mode_mappings) do
    if mapping.lhs == lhs then
      return mapping
    end
  end
end

describe('init.lua', function()
  it('removes bad default keymaps', function()
    init.main {
      plugins = {},
      mappings = true,
    }

    -- remove the default Y mapping
    assert.is.Nil(find_mapping('n', 'Y'), 'yank-line mapping is not roflstomped by neovim')
  end)
end)

local a = {
  describe = ptest.describe,
  it = ptest.it,
  before_each = ptest.before_each,
  after_each = ptest.after_each,
}

test_helper.setup()


a.describe('init.toggle_nvim_tree', function()
  init.main { plugins = { 'nvim-tree' } }

  a.after_each(function()
    vim.cmd('NvimTreeClose')
  end)

  a.it("opens the nvim tree when it's not visible", function()
    -- initially no nvim tree open
    assert.equals(nil, find_winnr_with_buffer_name('NvimTree_1'), 'nvim tree is closed')

    init.toggle_nvim_tree()

    local nvim_tree_winnr = find_winnr_with_buffer_name('NvimTree_1')
    assert.equals(true, nvim_tree_winnr ~= nil, 'nvim tree is open')
    assert.equals(vim.api.nvim_get_current_win(), nvim_tree_winnr, 'nvim tree is focused')
  end)

  a.it("Searches for the buffer's file in the tree", function()
    vim.cmd('edit tests/hjdivad/init_spec.lua')
    init.toggle_nvim_tree()
    wait()

    local nvim_tree_bufnr = find_bufnr_with_buffer_name('NvimTree_1')

    assert.is_not.Nil(nvim_tree_bufnr, 'nvim tree is open')

    local linenr = vim.fn.getcursorcharpos()[2]
    local line = vim.fn.getbufline(nvim_tree_bufnr, linenr)[1]

    assert.matches('.*%sinit_spec%.lua', line, 'nvim tree is open at the buffer')
  end)

end)
