local log = require("sticky-term/log")

local M = {}

local has_configured = false

---@class StickTermOptions
---@field log_level? string Initial log level ("fatal", "error", "warn", "info", "debug", "trace")
---@field log_to_file? boolean Whether to write log messages to disk

---@param options? StickTermOptions
function M.setup(options)
  log.trace("setup")

  local opts = vim.tbl_deep_extend("force", { log_level = "info", log_to_file = true }, options or {})

  log.set_level(opts.log_level)
  log.use_file(opts.log_to_file, true)

  has_configured = true
end

function M.find_visible_terminal_in_tab()
  log.trace("find_visible_terminal_in_tab")

  local windows_in_tab = vim.api.nvim_tabpage_list_wins(0)

  for _, win_id in ipairs(windows_in_tab) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_name = vim.api.nvim_buf_get_name(buf_id)

    log.trace(("win(%s): buf(%s: %s)"):format(win_id, buf_id, buf_name))
    if buf_name:match("^term://") then
      return win_id
    end
  end

  return nil
end

function M.find_neotree_window()
  local windows_in_tab = vim.api.nvim_tabpage_list_wins(0)

  for _, win_id in ipairs(windows_in_tab) do
    local win_ft = vim.api.nvim_get_option_value("filetype", { win = win_id })
    log.trace(("win(%s): ft(%s)"):format(win_id, win_ft))

    if win_ft == "neo-tree" then
      return win_id
    end
  end
end

function M.find_any_terminal_buffer()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf_id in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf_id)
    if string.match(name, "^term://") then
      return buf_id
    end
  end
end

function M.open_window_for_terminal()
  local neotree_win_id = M.find_neotree_window()
  if neotree_win_id then
    log.trace("split right of neo-tree win(%s)", neotree_win_id)
    local splitright_restore = vim.opt.splitright
    vim.opt.splitright = true
    vim.api.nvim_set_current_win(neotree_win_id)
    vim.cmd("vertical new")
    vim.opt.splitright = splitright_restore
  else
    log.trace("split topleft")
    vim.cmd("topleft vertical new")
  end

  local term_buf_id = M.find_any_terminal_buffer()
  if term_buf_id then
    vim.api.nvim_set_current_buf(term_buf_id)
  else
    vim.cmd("terminal")
  end
end

function M.goto_terminal()
  log.trace("goto_terminal")

  if not has_configured then
    -- set up with defaults
    M.setup()
  end

  local terminal_win = M.find_visible_terminal_in_tab()
  if terminal_win ~= nil then
    log.trace(("focus win: %s"):format(terminal_win))
    vim.api.nvim_set_current_win(terminal_win)
    return
  end

  M.open_window_for_terminal()
end

function M.set_log_level(level)
  log.set_level(level)
end

function M.show_logs()
  vim.cmd("tabnew " .. log.outfile)
end

return M
