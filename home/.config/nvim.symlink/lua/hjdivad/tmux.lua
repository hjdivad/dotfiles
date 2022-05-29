local utils = require('hjdivad/utils')

local function get_tmux_panes()
  local result = {}
  local tmux_panes = utils.get_os_command_output({
    'tmux', 'list-panes', '-a', '-F', '#{pane_id}⊱#{window_name}⊱#{session_name}'
  })
  for _, entry in ipairs(tmux_panes) do
    local partsIter = entry:gmatch('([^⊱]+)[⊱]?')
    local pane_id = partsIter()
    local window_name = partsIter()
    local session_name = partsIter()
    table.insert(result, { pane_id = pane_id, window_name = window_name, session_name = session_name })
  end
  return result
end

local function goto_tmux_session(session_name, window_name)
  local matching_pane = nil
  for _, pane in ipairs(get_tmux_panes()) do
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
    vim.api.nvim_err_writeln('Cannot find tmux pane "' .. tostring(session_name) .. ':' .. tostring(window_name) .. '"')
  end
end

return {
  _get_tmux_panes = get_tmux_panes,
  goto_tmux_session = goto_tmux_session,
}
