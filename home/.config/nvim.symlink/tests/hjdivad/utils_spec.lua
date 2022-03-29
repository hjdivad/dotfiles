local utils = require('hjdivad.utils')
local Path = utils.Path
local File = utils.File
local xdg_data_path = utils.xdg_data_path
local xdg_config_path = utils.xdg_config_path
local get_os_command_output = utils.get_os_command_output
local __set_env = utils.__set_env
local __reset = utils.__reset
local os_tmpdir = utils.os_tmpdir()

local __filename = debug.getinfo(1, 'S').source:sub(2)
local __dirname = Path.dirname(__filename)
local Fixtures = __dirname .. '/../fixtures'

local tmpdir

if os_tmpdir and (#os_tmpdir < 4 or os_tmpdir:sub(1, 1) ~= Path.Sep or os_tmpdir:find('"', 1, true)) then
  error('refusing to test with suspicious os_tmpdir: "' .. os_tmpdir .. '"')
else
  tmpdir = os_tmpdir .. Path.Sep .. 'hjdivad-init-test-tmp'
end

-- see <https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md>
-- see <http://olivinelabs.com/busted/#asserts>

describe('Path', function()
  it('.Sep exists', function() assert.equals('/', Path.Sep) end)

  it('.join creates valid paths', function()
    assert.equals('/', Path.join('/', ''))
    assert.equals('/foo', Path.join('/', 'foo'))
    assert.equals('/foo/', Path.join('/', 'foo/'))
    assert.equals('foo/bar/baz', Path.join('foo', 'bar', 'baz'))
    assert.equals('foo/bar/baz', Path.join('foo/', 'bar/', 'baz'))
    assert.equals('foo/bar/baz', Path.join('foo', '/bar/', '/baz'))
  end)

  it('.dirname computes the dirname of a paath', function()
    assert.equals('/', Path.dirname('/'))
    assert.equals('/', Path.dirname('/foo'))
    assert.equals('/foo', Path.dirname('/foo/bar'))
    assert.equals('/foo', Path.dirname('/foo/bar/'))
    assert.equals('/foo/bar', Path.dirname('/foo/bar/afile.ext'))
  end)
end)

describe('File', function()
  it('.readable returns true for readable file paths, false otherwise', function()
    assert.equals(true, File.readable(Fixtures .. '/afile'))
    assert.equals(false, File.readable(Fixtures .. '/no-such-file'))
  end)

  it('.isdirectory returns true for diretories', function()
    assert.equals(true, File.isdirectory(Fixtures .. '/foo'))
    assert.equals(true, File.isdirectory(Fixtures .. '/foo/bar'))
    assert.equals(false, File.isdirectory(Fixtures .. '/afile'))
    assert.equals(false, File.isdirectory(Fixtures .. '/no-such-file'))
  end)

  if tmpdir then
    before_each(function()
      os.execute('rm -rf "' .. tmpdir .. '"')
      os.execute('mkdir "' .. tmpdir .. '"')
    end)

    after_each(function() os.execute('rm -rf "' .. tmpdir .. '"') end)

    it('.cp_r copies files recursively', function()
      assert.equals(false, File.isdirectory(tmpdir .. '/foo'))
      assert.equals(false, File.isdirectory(tmpdir .. '/foo/bar'))
      assert.equals(false, File.readable(tmpdir .. '/foo/cfile'))
      assert.equals(false, File.readable(tmpdir .. '/foo/bar/dfile'))

      File.cp_r(Fixtures .. '/foo', tmpdir)

      assert.equals(true, File.isdirectory(tmpdir .. '/foo'))
      assert.equals(true, File.isdirectory(tmpdir .. '/foo/bar'))
      assert.equals(true, File.readable(tmpdir .. '/foo/cfile'))
      assert.equals(true, File.readable(tmpdir .. '/foo/bar/dfile'))
    end)
  else
    it('cannot test everything',
       function() error('cannot determine os.tmpdir, unable to test file writing') end)
  end
end)

describe('XDG helpers', function()
  after_each(function() __reset() end)

  it('xdg_data_path computes the xdg data path', function()
    -- no $XDG_DATA_HOME or $HOME
    __set_env({})
    assert.equals(nil, xdg_data_path())

    -- no XDG_DATA_HOME, but we have HOME
    __set_env({HOME = '/home/user'})
    assert.equals('/home/user/.local/share', xdg_data_path())

    -- XDG_DATA_HOME
    __set_env({XDG_DATA_HOME = '/some/absolute/path'})
    assert.equals('/some/absolute/path', xdg_data_path())

    -- invalid XDG_DATA_HOME ignored
    __set_env({XDG_DATA_HOME = 'relative/path'})
    assert.equals(nil, xdg_data_path())

    -- XDG_DATA_HOME takes precedence over HOME
    __set_env({XDG_DATA_HOME = '/some/absolute/path', HOME = '/home/user'})
    assert.equals('/some/absolute/path', xdg_data_path())

    -- invalid XDG_DATA_HOME ignored
    __set_env({XDG_DATA_HOME = 'relative/path', HOME = '/home/user'})
    assert.equals('/home/user/.local/share', xdg_data_path())
  end)

  it('xdg_config_path computes the xdg config path', function()
    -- no $XDG_CONFIG_HOME or $HOME
    __set_env({})
    assert.equals(nil, xdg_config_path())

    -- no XDG_CONFIG_HOME, but we have HOME
    __set_env({HOME = '/home/user'})
    assert.equals('/home/user/.config', xdg_config_path())

    -- XDG_CONFIG_HOME
    __set_env({XDG_CONFIG_HOME = '/some/absolute/path'})
    assert.equals('/some/absolute/path', xdg_config_path())

    -- invalid XDG_CONFIG_HOME ignored
    __set_env({XDG_CONFIG_HOME = 'relative/path'})
    assert.equals(nil, xdg_config_path())

    -- XDG_CONFIG_HOME takes precedence over HOME
    __set_env({XDG_CONFIG_HOME = '/some/absolute/path', HOME = '/home/user'})
    assert.equals('/some/absolute/path', xdg_config_path())

    -- invalid XDG_CONFIG_HOME ignored
    __set_env({XDG_CONFIG_HOME = 'relative/path', HOME = '/home/user'})
    assert.equals('/home/user/.config', xdg_config_path())
  end)
end)

describe('os helpers', function()
  it('get_os_command_output captures output from executing os commands', function()
    assert.same({'hello', 'from echo'}, get_os_command_output({'/bin/echo', 'hello\nfrom echo'}))
  end)
end)
