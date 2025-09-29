local M = {}

local agents = {
  claude = "claude --dangerously-skip-permissions",
  cursor = "cursor-agent -f",
}

local function do_start_agent(agent_cmd)
	-- Get current working directory and extract session name
	local cwd = vim.fn.getcwd()
	local path_parts = {}
	for part in string.gmatch(cwd, "[^/]+") do
		table.insert(path_parts, part)
	end

	-- Get last two directory components for session name
	local session_name
	if #path_parts >= 2 then
		session_name = path_parts[#path_parts - 1] .. "/" .. path_parts[#path_parts]
	elseif #path_parts == 1 then
		session_name = path_parts[1]
	else
		session_name = "unknown"
	end

	-- Create prompt file path
	local prompt_path = vim.fn.stdpath('cache') .. "/prompt/" .. session_name .. ".prompt.md"

	-- Ensure directory exists
	local prompt_dir = vim.fn.fnamemodify(prompt_path, ":h")
	vim.fn.mkdir(prompt_dir, "p")

	-- Open new tab
	vim.cmd("tabnew")

	-- Split vertically (creates left and right windows)
	vim.cmd("vsplit")

	-- Move to right window and start terminal with claude
	vim.cmd("wincmd l") -- Move to right window
	vim.cmd("term " .. agent_cmd)

	-- Move to left window and open prompt file
	vim.cmd("wincmd h") -- Move to left window
	vim.cmd("edit " .. prompt_path)
end

function M.StartAgent(agent)
  local agent_name = agent or 'claude'
  local agent_cmd = agents[agent_name]
  --FIXME: when we execute this eagerly, we run before the autocmds are set up and we don't get the prompt extensions.
  -- But when we execute in a VeryLazy callback, the filetype is never set, for some unknown reason.
  -- For now just execute eagerly, but we probably want to actually do this in a callback
  do_start_agent(agent_cmd)
end

return M
