local M = {}

local function augroup(name)
  return vim.api.nvim_create_augroup("hjd_term_" .. name, { clear = true })
end

function M.setup_terminal_window()
  local win_id = vim.api.nvim_get_current_win()
  local win = vim.wo[win_id]

  win.number = false
  win.relativenumber = false

  local win_config = vim.api.nvim_win_get_config(win_id)
  local is_not_float = win_config.relative == ""
end

function M.setup()
  local terminal_setup = augroup("terminal_setup")

  vim.api.nvim_create_autocmd({ "BufWinEnter", "TermOpen" }, {
    pattern = "term://*",
    group = terminal_setup,
    callback = function()
      vim.cmd("startinsert")
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    pattern = "term://*",
    group = terminal_setup,
    callback = M.setup_terminal_window,
  })

  vim.api.nvim_create_autocmd({ "WinEnter" }, {
    pattern = "term://*",
    group = terminal_setup,
    callback = function()
      -- when creating a new window from a terminal, we'll WinEnter from the old
      -- terminal before switching to [No Name] and then opening a new terminal
      -- we don't want to startinsert while we're on [No Name], but rather wait
      -- until we've made it into the terminal
      vim.schedule(function()
        if vim.startswith(vim.api.nvim_buf_get_name(0), "term://") then
          vim.cmd("startinsert")
        end
      end)
    end,
  })

  -- TODO: unset this stuff on bufleaving a term
  vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = terminal_setup,
    callback = M.setup_terminal_window,
  })
end

return M
