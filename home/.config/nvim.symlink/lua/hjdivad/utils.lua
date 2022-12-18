--TODO: purify
local telescope_utils = require('telescope.utils')
local Job = require 'plenary.job'
local Log = require('plenary.log')

local level = 'info'
if vim.fn.getenv('DEBUG') ~= vim.NIL then
  level = 'trace'
end

local M = {}

M.log = Log.new {
  plugin = 'hjdivad_init',
  level = level,
  -- TODO: this does write to $HOME/.cache/nvim/hjdivad_init.log
  -- but does not seem to write to the console at all
  use_console = 'sync',
}

--TODO: delete global
---Global access; entry point for autocommands and mappings
---@diagnostic disable-next-line: lowercase-global
ha = {}
M.ha = ha
M.hjdivad_auto = ha

local startswith = vim.startswith
local endswith = vim.endswith
local env = vim.env

---Sets the object used to read environment veriables within this package
---Only intended for testing
---
---@param new_env any
function M.__set_env(new_env) env = new_env end

---Reset any mutations done via `__set_env`
function M.__reset() env = vim.env end

function M.os_tmpdir()
  return os.getenv('TMPDIR') and os.getenv('TMPDIR') or os.getenv('TEMP') or '/tmp'
end

---Prints messages in `...`
---
---intended for simple printf debugging. For anthing advanced see vim.notify()
function M.echo(...)
  local args = { n = select('#', ...), ... }
  local messages = {}
  for i = 1, args.n do
    local msg = args[i]
    table.insert(messages, { ' ' .. tostring(msg) })
  end

  vim.api.nvim_echo(messages, true, {})
end

-- TODO: vim.tbl_extend
function M.assign(target, source)
  for k, v in ipairs(source or {}) do target[k] = v end

  return target
end

local Path = {}
M.Path = Path
Path.Sep = '/'

function Path.join(root, ...)
  local result = root
  for _, next_path in ipairs({ ... }) do
    if endswith(result, Path.Sep) then
      if startswith(next_path, Path.Sep) then
        result = result .. next_path:sub(2)
      else
        result = result .. next_path
      end
    else
      if startswith(next_path, Path.Sep) then
        result = result .. next_path
      else
        result = result .. Path.Sep .. next_path
      end
    end
  end
  return result
end

---Computes the directory portion of a path
---see `man basename(1)`
---
---**Examples**:
---```lua
---Path.dirname('/') == '/'
---Path.dirname('/foo') == '/'
---Path.dirname('/foo/bar') == '/foo'
---Path.dirname('foo') == '.'
---```
---
---@param path string
---@return string
function Path.dirname(path)
  local idx = nil
  local next_sep_idx = 1

  if not path:find(Path.Sep) then return '.' end

  repeat
    idx = next_sep_idx - 1
    next_sep_idx = path:find(Path.Sep, next_sep_idx + 1, true)
  until not next_sep_idx or next_sep_idx == #path

  if idx == 0 then return '/' end

  return path:sub(1, idx)
end

function Path.isabsolute(path) return path:sub(1, 1) == Path.Sep end

local File = {}
M.File = File
function File.readable(path)
  local file = io.open(path, 'r')
  if file then
    file:close()
    return true
  else
    return false
  end
end

function File.cp_r(path, dest) Job:new({ command = 'cp', args = { '-r', path, dest } }):sync() end

---Returns `true` if `path` is a directory, `false` otherwise.
---@see `:help isdirectory()`
---
---@param path string
---@return boolean
function File.isdirectory(path) return vim.fn['isdirectory'](path) == 1 end

function M.xdg_data_path(relpath)
  -- see <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
  local xdg_dir =
  (env.XDG_DATA_HOME and Path.isabsolute(env.XDG_DATA_HOME) and env.XDG_DATA_HOME) or
      (env.HOME and Path.join(env.HOME, '.local', 'share'))
  return xdg_dir and Path.join(xdg_dir, relpath) or nil
end

function M.xdg_config_path(relpath)
  -- see <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
  local xdg_dir = (env.XDG_CONFIG_HOME and Path.isabsolute(env.XDG_CONFIG_HOME) and
      env.XDG_CONFIG_HOME) or (env.HOME and Path.join(env.HOME, '.config'))
  return xdg_dir and Path.join(xdg_dir, relpath) or nil
end

function M.tbl_find(func, t)
  for index, value in ipairs(t) do
    if func(value, index) then
      return value
    end
  end
end

---@param cmd table { command, [arg...] }
---@param cwd string
M.get_os_command_output = telescope_utils.get_os_command_output

return M
