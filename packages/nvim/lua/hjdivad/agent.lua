local M = {}

-- obviously only run these in trusted directories
local agents = {
  claude = "claude --dangerously-skip-permissions",
  cursor = "cursor-agent --force --approve-mcps",
  codex = "codex",
}

local default_agent = 'codex'

local function session_name(cwd)
  local path_parts = {}
  for part in string.gmatch(cwd, "[^/]+") do
    table.insert(path_parts, part)
  end

  if #path_parts >= 2 then
    return path_parts[#path_parts - 1] .. "/" .. path_parts[#path_parts]
  elseif #path_parts == 1 then
    return path_parts[1]
  else
    return "unknown"
  end
end

local function env_path(env_name, fallback)
  local path = vim.env[env_name]
  if path == nil or path == "" then
    return fallback
  end

  return path
end

local function agent_paths(cwd)
  local name = session_name(cwd)
  local base = vim.fn.stdpath("cache") .. "/prompt/" .. name

  return {
    prompt = env_path("AGENTS_PROMPT", base .. ".prompt.md"),
    vadnu = env_path("AGENTS_VADNU", base .. ".vadnu.md"),
  }
end

local function ensure_parent_dir(path)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

local function ensure_vadnu_file(path)
  ensure_parent_dir(path)

  if vim.fn.filereadable(path) == 1 then
    return
  end

  vim.fn.writefile({ "## Stack", "## Tasks" }, path)
end

local function do_start_agent(agent_cmd)
  local paths = agent_paths(vim.fn.getcwd())

  ensure_vadnu_file(paths.vadnu)
  ensure_parent_dir(paths.prompt)

  vim.cmd("tabnew")
  vim.cmd("rightbelow vsplit")
  vim.cmd("rightbelow vsplit")
  vim.cmd("term " .. agent_cmd)
  vim.cmd("wincmd h")
  vim.cmd("edit " .. vim.fn.fnameescape(paths.vadnu))
  vim.cmd("rightbelow split")
  vim.cmd("edit " .. vim.fn.fnameescape(paths.prompt))
  vim.cmd("setlocal winfixheight")
  vim.cmd("resize 15")
  vim.cmd("wincmd h")
  vim.cmd("terminal")
  vim.cmd("rightbelow split")
  vim.cmd("terminal")
  vim.cmd("wincmd l")
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 100)
end

function M.StartAgent(agent)
  local agent_name = agent or default_agent
  local agent_cmd = agents[agent_name]
  --FIXME: when we execute this eagerly, we run before the autocmds are set up and we don't get the prompt extensions.
  -- But when we execute in a VeryLazy callback, the filetype is never set, for some unknown reason.
  -- For now just execute eagerly, but we probably want to actually do this in a callback
  do_start_agent(agent_cmd)
end

M._agent_paths = agent_paths
M._ensure_vadnu_file = ensure_vadnu_file
M._session_name = session_name

return M
