local utils = require('hjdivad.utils')
local hi = utils.hjdivad_init
local ha = utils.hjdivad_auto


local function get_terminal_expected_width()
  local is_reasonable_screen = vim.o.columns >= 220

  if is_reasonable_screen then
    return 120
  else
    return 79
  end
end


---Set up window local options when its buffer is a terminal.
--- * disable editor gutter marks like line numbers
--- * resize to desired terminal width
--- * add a <c-w>n mapping that opens a terminal rather than an empty new window
function ha.terminal_onopen()
  vim.wo.winfixwidth = true
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.cmd([[vertical resize]] .. get_terminal_expected_width())
  vim.api.nvim_buf_set_keymap(0 --[[current buffer]], 'n', '<c-w>n', '<cmd>aboveleft Tnew<cr><cmd>start<cr>', {})
  vim.api.nvim_buf_set_keymap(0 --[[current buffer]], 'n', '<c-w><c-n>', '<cmd>aboveleft Tnew<cr><cmd>start<cr>', {})
end

function ha.terminal_onclose()
  vim.wo.winfixwidth = false
end

---When entering a terminal window, automatically enter insert mode
---if the prompt line (i.e. the last line of the buffer) is visible.
---
---This means most of the time, one auto-enters insert, but not after
---scrolling back through terminal history in normal mode.
function ha.terminal_onbufenter()
  local last_line_visible = vim.fn['line']('w$')
  local line_count = vim.api.nvim_buf_line_count(0)
  local is_prompt_visible = last_line_visible >= line_count
  if is_prompt_visible then
    vim.cmd('start!')
  end
end

local function setup_terminal()
  vim.cmd([[
    augroup TermEnter
      autocmd!
      autocmd TermOpen * lua ha.terminal_onopen()
      autocmd TermClose * lua ha.terminal_onclose()
      autocmd BufEnter term://* lua ha.terminal_onbufenter()
      " terminal commands might edit files we have in buffers
      autocmd WinLeave term://* :checktime
    augroup end
  ]])
end

function ha.toggle_terminal()
  local open_terminals = ha.get_neoterm_window_ids()
  if #open_terminals > 0 then
    -- TODO: handle the case of a terminal being on a different tab

    -- arbitrarily pick the first terminal to focus
    vim.fn['win_gotoid'](open_terminals[1])
  else
    vim.cmd([[vertical topleft Ttoggle]])
    -- Ttoggle for an existing terminal with no window doesn't trigger TermOpen
    ha.terminal_onopen()
  end
end

function ha.get_neoterm_window_ids()
  local result = {}
  for _, term in pairs(vim.g.neoterm.instances) do
    local buf_id = term.buffer_id
    local win_id = vim.fn['bufwinid'](buf_id)
    if win_id and win_id > -1 then
      table.insert(result, win_id)
    end
  end
  return result
end

function hi.resize()
  local etw = get_terminal_expected_width()
  vim.cmd([[vertical resize ]] .. etw)
  for _, win_id in ipairs(ha.get_neoterm_window_ids()) do
    vim.fn['win_execute'](win_id, 'vertical resize ' .. etw)
  end
end


return {
  setup_terminal = setup_terminal,
}

