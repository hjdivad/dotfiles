local spy = require('luassert/spy')
local stub = require('luassert/stub')
local mock = require('luassert/mock')

local test_helper = require('hjdivad/test_helper')

local exrc = require('hjdivad/exrc')

test_helper.setup()

describe('exrc', function()
  describe('_get_data_path', function()
    it("returns the plugin's saved choices file within $XDG_DATA_HOME", function()
      assert.equals(vim.fn.stdpath('data') .. '/hjdivad-init/exrc_dir_choices', exrc._get_data_path())
    end)
  end)

  describe('_exrc', function()
    local spy_loadfile
    local mock_io
    local mock_fs
    local restore_rtp

    local function _exrc(vimrc, vim_rtp)
      return exrc._exrc(vimrc, vim_rtp, { ['loadfile'] = spy_loadfile, ['io'] = mock_io })
    end

    before_each(function()
      spy_loadfile = spy.new(function() end)
      mock_fs = {}
      mock_io = mock({
        open = function(path)
          return mock({
            read = function()
              return mock_fs[path]
            end
          })
        end
      })
      restore_rtp = vim.opt.runtimepath
      stub(vim.api, 'nvim_exec')
    end)

    after_each(function()
      vim.opt.runtimepath = restore_rtp
      vim.api.nvim_exec:revert()
    end)

    it('updates runtimepath', function()
      _exrc(nil, './foo')

      assert.spy(spy_loadfile).was_not_called()
      assert.stub(vim.api.nvim_exec).was_not_called()
      assert.matches('.*,?%./foo', vim.opt.runtimepath._value)
    end)

    it('executes .vimrc.lua', function()
      _exrc('.vimrc.lua', nil)

      assert.spy(spy_loadfile).was_called_with('.vimrc.lua', 't')
      assert.stub(vim.api.nvim_exec).was_not_called()
      assert.equals(restore_rtp._value, vim.opt.runtimepath._value, 'runtimepath is unmodified')
    end)

    it('executes .vimrc', function()
      mock_fs['.vimrc'] = 'VIMRC'
      _exrc('.vimrc', nil)

      assert.spy(spy_loadfile).was_not_called()
      assert.spy(mock_io.open).was_called_with('.vimrc', 'r')
      assert.stub(vim.api.nvim_exec).was_called_with('VIMRC', false)
      assert.equals(restore_rtp._value, vim.opt.runtimepath._value, 'runtimepath is unmodified')
    end)

    it('executes vimrc and updates runtimepath', function()
      _exrc('.vimrc.lua', './foo')

      assert.spy(spy_loadfile).was_called_with('.vimrc.lua', 't')
      assert.stub(vim.api.nvim_exec).was_not_called()
      assert.matches('.*,?%./foo', vim.opt.runtimepath._value)
    end)

    it('errors if given neither vimrc nor runtimepath', function()
      local success = pcall(_exrc, nil, nil)
      assert.equals(false, success)
    end)
  end)
end)
