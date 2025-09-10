local M = {}

---@param cmd string[]
---@return string[] lines
local function sys(cmd)
  local result = vim.system(cmd):wait()

  if result.code == 0 then
    local output = result.stdout -- get the standard output
    local lines = {}

    if output == nil then
      return lines
    end

    for line in output:gmatch("([^\n]*)\n?") do
      if line ~= "" then
        table.insert(lines, line)
      end
    end

    return lines
  else
    -- Throw an error that includes the command and stderr
    local cmd_str = table.concat(cmd, " ")
    error(string.format("Command failed: %s\nError: %s", cmd_str, result.stderr))
  end
end

---@class TmuxPaneInfo
---@field pane_id string
---@field window_name string
---@field session_name string

---@class GetTmuxPaneOptions
---@field socket_name string|nil

---@param options GetTmuxPaneOptions|nil
---@return TmuxPaneInfo[]
function M.get_tmux_panes(options)
  ---@type GetTmuxPaneOptions
  local opts = vim.tbl_deep_extend("force", {}, options or {})

  local cmd = { "tmux" }
  if opts.socket_name then
    vim.list_extend(cmd, { "-L", opts.socket_name })
  end

  vim.list_extend(cmd, {
    "list-panes",
    "-a",
    "-F",
    "#{pane_id}⊱#{window_name}⊱#{session_name}",
  })

  ---@type TmuxPaneInfo[]
  local result = {}
  local tmux_panes = sys(cmd)
  for _, entry in ipairs(tmux_panes) do
    local partsIter = entry:gmatch("([^⊱]+)[⊱]?")
    local pane_id = partsIter()
    local window_name = partsIter()
    local session_name = partsIter()
    table.insert(result, { pane_id = pane_id, window_name = window_name, session_name = session_name })
  end
  return result
end

function M.goto_tmux_session(session_name, window_name)
  local matching_pane = nil
  for _, pane in ipairs(M.get_tmux_panes()) do
    if session_name == pane.session_name then
      if window_name == pane.window_name then
        matching_pane = pane
        break
      end
    end
  end

  if matching_pane then
    vim.api.nvim_command([[silent !tmux switch-client -t \\]] .. matching_pane.pane_id)
  else
    vim.api.nvim_err_writeln('Cannot find tmux pane "' .. tostring(session_name) .. ":" .. tostring(window_name) .. '"')
  end
end

---@param pane TmuxPaneInfo
function M._pane_info_to_selection_string(pane)
  -- see <https://github.com/ibhagwan/fzf-lua/blob/8f9c3a2e308755c25630087f3c5d35786803cfd0/lua/fzf-lua/utils.lua#L577-L595>
  local c = require('fzf-lua').utils.ansi_codes

  return  c.yellow(" " .. pane.session_name .. " ") .. " " .. pane.window_name .. " " .. c.grey("(" .. pane.pane_id .. ")")
end

---@param selection string
---@return TmuxPaneInfo
function M._selection_string_to_pane_info(selection)
  local parts = {}

  for part in selection:gmatch("[^ ]+") do
    table.insert(parts, part)
  end
  ---@type TmuxPaneInfo
  local pane_info = {
    session_name = parts[1],
    window_name = parts[2],
    pane_id = parts[3]:sub(2,-2)
  }
  return pane_info
end

---@param selected string[]
---@param opts GotoFzfTmuxSessionOptions
function M._fzf_lua_action_default(selected, opts)
  if #selected == 0 then
    return
  end

  local pane_info = M._selection_string_to_pane_info(selected[1])
  M.goto_tmux_session(pane_info.session_name, pane_info.window_name)

  if opts.quit_on_selection then
    vim.cmd('quitall')
  end
end

---@class GotoFzfTmuxSessionOptions
---@field quit_on_selection boolean | nil
---
---@param options GotoFzfTmuxSessionOptions
function M.goto_fzf_tmux_session(options)
  ---@type GotoFzfTmuxSessionOptions
  local defaults = {
    quit_on_selection = false
  }
  ---@type GotoFzfTmuxSessionOptions
  local opts = vim.tbl_deep_extend("force", defaults, options or {})

  -- see <https://github.com/ibhagwan/fzf-lua/blob/8f9c3a2e308755c25630087f3c5d35786803cfd0/lua/fzf-lua/utils.lua#L577-L595>
  local panes = M.get_tmux_panes()
  local selections = {}

  for _, pane in ipairs(panes) do
    selections[#selections+1] = M._pane_info_to_selection_string(pane)
  end

  -- see <https://github.com/ibhagwan/fzf-lua/wiki/Advanced>
  require('fzf-lua').fzf_exec(selections, {
    prompt = "Go to tmux window ❯ ",
    actions = {
      ---@param selected string[]
      ['default'] = function (selected, _)
        M._fzf_lua_action_default(selected, opts)
      end
    }
  })
end

return M
