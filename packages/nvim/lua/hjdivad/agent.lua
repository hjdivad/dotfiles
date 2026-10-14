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

  vim.fn.writefile({ "## Tasks" }, path)
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

local tree_ready_timeout_ms = 2000

-- Show a filesystem tree rooted at dir in the current tab, without changing
-- the tab's cwd and without moving focus.
--
-- Neo-tree debounces navigation and renders asynchronously, then jumps back to
-- the window that was current when the tree was requested. Wait for that to
-- finish so a later tab doesn't get this tab's tree or lose focus to it.
local function show_filesystem_tree(dir)
  local win = vim.api.nvim_get_current_win()
  -- Neo-tree keeps filesystem state per tab, so this only affects this tab.
  local state = require("neo-tree.sources.manager").get_state("filesystem")
  state.bind_to_cwd = false

  require("neo-tree.command").execute({
    action = "show",
    source = "filesystem",
    dir = dir,
  })

  local renderer = require("neo-tree.ui.renderer")
  local ready = vim.wait(tree_ready_timeout_ms, function()
    return state._ready == true
      and renderer.window_exists(state)
      and vim.api.nvim_get_current_win() == win
  end, 10)

  if not ready then
    vim.notify("Timed out waiting for neo-tree at " .. dir, vim.log.levels.WARN)
  end
end

local function open_terminal_grid()
  vim.cmd("tabnew")
  vim.cmd("terminal")
  vim.cmd("rightbelow vsplit")
  vim.cmd("terminal")
  vim.cmd("rightbelow split")
  vim.cmd("terminal")
  vim.cmd("wincmd h")
  vim.cmd("rightbelow split")
  vim.cmd("terminal")
  vim.cmd("wincmd =")
end

--- Open a workspace for working alongside an external agent.
---
--- Tab 1: filesystem tree at cwd, with the startup window on the right.
--- Tab 2: filesystem tree at $AGENTS_PROJECT (or $P), with vadnu.md on the
---        right. The tab's cwd stays at cwd. Skipped when neither is set.
--- Tab 3: a 2x2 grid of terminals.
---
--- Focus ends on tab 2's vadnu.md, or tab 1's main window without tab 2.
function M.StartExternalAgentWorkspace()
  local cwd = vim.fn.getcwd()
  local project = env_path("AGENTS_PROJECT", env_path("P", nil))
  if project ~= nil then
    -- Older worktrees set a cwd-relative AGENTS_PROJECT; give neo-tree a clean absolute root.
    project = vim.fs.normalize(vim.fn.fnamemodify(project, ":p"))
  end

  local focus_win = vim.api.nvim_get_current_win()
  show_filesystem_tree(cwd)

  if project ~= nil then
    local vadnu = project .. "/vadnu.md"
    ensure_vadnu_file(vadnu)

    vim.cmd("tabnew")
    vim.cmd("edit " .. vim.fn.fnameescape(vadnu))
    focus_win = vim.api.nvim_get_current_win()
    show_filesystem_tree(project)
  end

  open_terminal_grid()

  vim.api.nvim_set_current_win(focus_win)
end

function M.StartAgent(agent)
  local agent_name = agent or default_agent
  local agent_cmd = agents[agent_name]
  if agent == nil then
    agent_cmd = env_path("NVIM_AGENT_CMD", agent_cmd)
  end
  --FIXME: when we execute this eagerly, we run before the autocmds are set up and we don't get the prompt extensions.
  -- But when we execute in a VeryLazy callback, the filetype is never set, for some unknown reason.
  -- For now just execute eagerly, but we probably want to actually do this in a callback
  do_start_agent(agent_cmd)
end

M._agent_paths = agent_paths
M._ensure_vadnu_file = ensure_vadnu_file
M._session_name = session_name

return M
