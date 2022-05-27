local main = require('hjdivad_init').main

describe('init.lua', function()
  it('removes bad default keymaps', function()
    main()

    -- remove the default Y mapping
    assert.equals(nil, vim.api.nvim_get_keymap('n')['Y'])
  end)
end)
