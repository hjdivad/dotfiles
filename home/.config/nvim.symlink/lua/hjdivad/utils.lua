local telescope_utils = require('telescope.utils')
local Job = require'plenary.job'

---Global access; used for user-accessible API from ex mode and as entry
---points from autocommands
hi = {}
---Global access; entry point for autocommands and mappings
---@diagnostic disable-next-line: lowercase-global
ha = {}

local startswith = vim.startswith
local endswith = vim.endswith

---Prints messages in `...`
---
---intended for simple printf debugging. For anthing advanced see vim.notify()
local function echo(...)
  local args = { n = select('#', ...), ...}
  local messages = {}
  for i = 1, args.n do
    local msg = args[i]
    table.insert(messages, {' ' .. tostring(msg)})
  end

  vim.api.nvim_echo(messages, true, {})
end

-- TODO: vim.tbl_extend
local function assign(target, source)
  for k,v in ipairs(source or {}) do
    target[k] = v
  end

  return target
end

local Path = {}
Path.Sep = '/'

function Path.join(root, ...)
  local result = root
  for _, next_path in ipairs({...}) do
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

  if not path:find(Path.Sep) then
    return '.'
  end

  repeat
    idx = next_sep_idx - 1
    next_sep_idx = path:find(Path.Sep, next_sep_idx + 1, true)
  until not next_sep_idx or next_sep_idx == #path

  if idx == 0 then
    return '/'
  end

  return path:sub(1, idx)
end

local File = {}
function File.readable(path)
  local file = io.open(path, 'r')
  if file then
    file:close()
    return true
  else
    return false
  end
end

function File.cp_r(path, dest)
  Job:new({
    command = 'cp',
    args = { '-r', path, dest },
  }):sync()
end

---Returns `true` if `path` is a directory, `false` otherwise.
---@see `:help isdirectory()`
---
---@param path string
---@return boolean
function File.isdirectory(path)
  return vim.fn['isdirectory'](path) == 1
end

local function xdg_data_path(relpath)
  -- see <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
  local xdg_dir = vim.env.XDG_DATA_HOME or (vim.env.HOME .. '/.local/share')
  return Path.join(xdg_dir, relpath)
end

local function xdg_config_path(relpath)
  -- see <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
  local xdg_dir = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. '/.config')
  return Path.join(xdg_dir, relpath)
end

return {
  hjdivad_init = hi,
  hjdivad_auto = ha,
  echo = echo,
  assign = assign,
  Path = Path,
  File = File,
  xdg_data_path = xdg_data_path,
  xdg_config_path = xdg_config_path,
  get_os_command_output = telescope_utils.get_os_command_output,
}

