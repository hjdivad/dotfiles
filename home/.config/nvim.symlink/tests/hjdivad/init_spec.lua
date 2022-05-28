local main = require('hjdivad_init').main

local function find_mapping(mode, lhs)
  local mode_mappings = vim.api.nvim_get_keymap('n')
  for _, mapping in ipairs(mode_mappings) do
    if mapping.lhs == lhs then
      return mapping
    end
  end
end

describe('init.lua', function()
  it('removes bad default keymaps', function()
    main {
      plugins = {},
      mappings = true,
    }

    -- remove the default Y mapping
    assert.is.Nil(find_mapping('n', 'Y'), 'yank-line mapping is not roflstomped by neovim')
  end)
end)
