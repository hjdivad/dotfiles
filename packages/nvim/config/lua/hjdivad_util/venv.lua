---@class PythonEntryPoint
---@field name string
---@field pkg string
---@field fn string

-- see :he dap-configuration
-- see :dap-python.DebugpyLaunchConfig
---@class DapConfiguration
---@field type string python
---@field request string launch | attach
---@field name string user-friendly name of the configuration
---@field module? string
---@field program? string
---@field code? string code to execute
---@field args? string[] | nil command-line args for the program
---@field python? string[] path to python and interpreter arguments
---@field cwd? string
---@field env? table
---@field stopOnEntry? boolean

local TOML = require("toml")
local VenvSelector = require("venv-selector")

local Venv = {}
Venv.__index = Venv

function Venv:new()
  local instance = {}
  setmetatable(instance, Venv)
  return instance
end
--
---@param search_start_dir? string
---@return string | nil
function Venv.find_pyproject_toml(search_start_dir)
  -- Iterate upwards from search_start_dir
  while search_start_dir ~= "" do
    -- Check if pyproject.toml exists in the current directory
    local pyproject_toml_path = search_start_dir .. "/pyproject.toml"
    if vim.fn.filereadable(pyproject_toml_path) == 1 then
      return pyproject_toml_path
    end

    -- Move up one directory
    search_start_dir = vim.fn.fnamemodify(search_start_dir, ":h")
  end

  -- If no pyproject.toml is found, return nil
  return nil
end

---@param search_start_dir string
function Venv.load_pyproject(search_start_dir)
  local pyproject_path = Venv.find_pyproject_toml(search_start_dir)

  if pyproject_path == nil then
    return nil
  end

  local pyproject_config = Venv.parse_pyproject(pyproject_path)

  return pyproject_config
end

---@param path string
function Venv.parse_pyproject(path)
  local file_contents = io.open(path, "r"):read("*a")
  local pyproject = TOML.parse(file_contents)
  return pyproject
end

function Venv.extract_entrypoints(pyproject)
  local result = {}

  local p = pyproject
  if p.project and p.project.scripts then
    result = vim.tbl_extend("keep", result, p.project.scripts)
  end

  if p.tool then
    if p.tool.poetry and p.tool.poetry.scripts then
      result = vim.tbl_extend("keep", result, p.tool.poetry.scripts)
    end

    if p.tool.setuptools and p.tool.setuptools.entry_points then
      result = vim.tbl_extend("keep", result, p.tool.setuptools.entry_points)
    end

    if p.tool.flit then
      if p.tool.flit.scripts then
        result = vim.tbl_extend("keep", result, p.tool.flipt.scripts)
      end

      if p.tool.flit.entrypoints then
        result = vim.tbl_extend("keep", result, p.tool.flipt.entrypoints)
      end
    end
  end

  return result
end

function Venv.get_venv()
  local venv_path = VenvSelector.get_active_venv()
  if venv_path == nil then
    -- try to load last venv
    VenvSelector.retrieve_from_cache()
    venv_path = VenvSelector.get_active_venv()
  end

  local python_path = VenvSelector.get_active_path()

  return python_path, venv_path
end

function Venv.get_and_check_venv()
  local python_path, venv_path = Venv.get_venv()

  if venv_path == nil then
    require("noice").redirect(function()
      print("No python venv detected.  Run :VenvSelect.")
    end)
    return
  end

  return python_path, venv_path
end

---@param name string
---@param args string[] | nil
function Venv.dap_configuration(name, cmd, args)
  local python_path, venv_path = Venv.get_and_check_venv()

  if venv_path == nil then
    return {}
  end

  cmd = cmd or name

  local program

  if cmd:find('/') then
    program = cmd
  else
    program = venv_path .. "/bin/" .. cmd
  end


  ---@type DapConfiguration
  local result = {
    type = "python",
    request = "launch",
    name = name,
    python = { python_path },
    program = program,
  }

  if args ~= nil then
    result.args = args
  end

  return result
end

---@return DapConfiguration[]
function Venv:dap_configurations()
  local pyproject = Venv.load_pyproject(vim.fn.getcwd())
  if pyproject == nil then
    return {}
  end

  local python_path = Venv.get_and_check_venv()

  if python_path == nil then
    return {}
  end

  local entrypoints = Venv.extract_entrypoints(pyproject)
  local entrypooint_runnables = vim.tbl_keys(entrypoints)
  local configs = vim.tbl_map(Venv.dap_configuration, entrypooint_runnables)
  return configs
end

return Venv:new()
