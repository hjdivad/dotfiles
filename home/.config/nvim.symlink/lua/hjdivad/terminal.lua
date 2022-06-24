local utils = require('hjdivad/utils')

local M = {}
local log = utils.log

--TODO: do i need neoterm at all?

---Private API exported for testing
---
---@private
---@return integer
local function get_terminal_expected_width()
  local is_reasonable_screen = vim.o.columns >= 220

  if is_reasonable_screen then
    return 120
  else
    return 79
  end
end

M._get_terminal_expected_width = get_terminal_expected_width

local function get_neoterm_window_ids()
  local result = {}
  for _, term in pairs(vim.g.neoterm.instances) do
    local buf_id = term.buffer_id
    local win_id = vim.fn['bufwinid'](buf_id)
    if win_id and win_id > -1 then table.insert(result, win_id) end
  end
  return result
end

---When entering a terminal window, automatically enter insert mode
---if the prompt line (i.e. the last line of the buffer) is visible.
---
---This means most of the time, one auto-enters insert, but not after
---scrolling back through terminal history in normal mode.
local function insert_if_prompt_visible()
  local bufnr = vim.fn.bufnr()
  --Add a level of async. Right when BufWinEnter fires, we won't get the right
  --value from vim.fn.line('w$'), so we wait a tick to know whether the prompt is actually visible.
  --Doing this requires us to check that the buffer is the same or we'll have
  --occasional "insert mode" bugs when switching from a terminal.
  vim.schedule(function()
    if bufnr ~= vim.fn.bufnr() then
      return
    end

    local last_line_visible = vim.fn.line('w$')
    local line_count = vim.api.nvim_buf_line_count(0)
    local is_prompt_visible = last_line_visible >= line_count
    if is_prompt_visible then
      vim.cmd('start!')
    end
  end)
end

local function resize_terminal_windows(options)
  local opts = vim.tbl_deep_extend('force', { all = false }, options or {})
  local etw = get_terminal_expected_width()
  vim.api.nvim_win_set_width(0, etw)

  if opts.all then
    for _, win_id in ipairs(get_neoterm_window_ids()) do
      vim.api.nvim_win_set_width(win_id, etw)
    end
  end
end

local autocmd_ids = {}
local saved_vim_options = {}
local function setup_terminal_autocommands(options)
  table.insert(autocmd_ids, vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TermOpen' }, {
    pattern = 'term://*',
    callback = function()
      if #saved_vim_options == 0 then
        saved_vim_options.wfw = vim.o.winfixwidth
        saved_vim_options.num = vim.o.number
        saved_vim_options.relnum = vim.o.relativenumber
        saved_vim_options.spell = vim.o.spell
      end
      vim.wo.winfixwidth = true
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.spell = false
      resize_terminal_windows {}
      insert_if_prompt_visible()
      if options.mappings then
        vim.api.nvim_buf_set_keymap(0--[[current buffer]] , 'n', '<c-w>n',
          '<cmd>aboveleft Tnew<cr><cmd>start<cr>', {})
        vim.api.nvim_buf_set_keymap(0--[[current buffer]] , 'n', '<c-w><c-n>',
          '<cmd>aboveleft Tnew<cr><cmd>start<cr>', {})
      end
    end,
  }))
  table.insert(autocmd_ids, vim.api.nvim_create_autocmd('WinLeave', {
    pattern = 'term://*',
    -- terminal commands might edit files we have in buffers
    command = 'checktime'
  }))
  table.insert(autocmd_ids, vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
    pattern = 'term://*',
    callback = function()
      vim.wo.wfw = saved_vim_options.wfw
      vim.wo.number = saved_vim_options.num
      vim.wo.relativenumber = saved_vim_options.relnum
      vim.wo.spell = saved_vim_options.spell
    end,
  }))
  table.insert(autocmd_ids, vim.api.nvim_create_autocmd('VimResized', {
    pattern = '*',
    callback = resize_terminal_windows,
  }))
end

local function setup_terminal_mappings()
  vim.keymap.set('t', '<c-w>h', [[<c-\><c-n><c-w>h]], { desc = 'win-left (in terminal)', })
  vim.keymap.set('t', '<c-w><c-h>', [[<c-\><c-n><c-w>h]], { desc = 'win-left (in terminal)', })
  vim.keymap.set('t', '<c-w>j', [[<c-\><c-n><c-w>j]], { desc = 'win-down (in terminal)', })
  vim.keymap.set('t', '<c-w><c-j>', [[<c-\><c-n><c-w>j]], { desc = 'win-down (in terminal)', })
  vim.keymap.set('t', '<c-w>k', [[<c-\><c-n><c-w>k]], { desc = 'win-up (in terminal)', })
  vim.keymap.set('t', '<c-w><c-k>', [[<c-\><c-n><c-w>k]], { desc = 'win-up (in terminal)', })
  vim.keymap.set('t', '<c-w>l', [[<c-\><c-n><c-w>l]], { desc = 'win-right (in terminal)', })
  vim.keymap.set('t', '<c-w><c-l>', [[<c-\><c-n><c-w>l]], { desc = 'win-right (in terminal)', })
  vim.keymap.set('t', '<c-w>c', [[<c-\><c-n><c-w>c]], { desc = 'win-close (in terminal)', })
  vim.keymap.set('t', '<c-w><c-c>', [[<c-\><c-n><c-w>c]], { desc = 'win-close (in terminal)', })
  -- escape and re-enter insert mode to prevent issue with cursor not appearing in new terminal window
  vim.keymap.set('t', '<c-w>n', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]], { desc = 'win-new (in terminal)', })
  vim.keymap.set('t', '<c-w><c-n>', [[<cmd>aboveleft Tnew<cr><c-\><c-n><cmd>start<cr>]],
    { desc = 'win-new (in terminal)', })
end

local function setup_terminal(options)
  setup_terminal_autocommands(options)

  if options.mappings then
    setup_terminal_mappings()
  end
end

---Focus the window with the neoterm terminal
---
---If there are no visible terminals, toggle the first open one (i.e. show it
---in a window). If there are no terminals at all, create one in a window at
---the top left.
---
---If there are multiple open terminals, open the first one.
function M.toggle_terminal()
  local open_terminals = get_neoterm_window_ids()
  if #open_terminals > 0 then
    -- TODO: handle the case of a terminal being on a different tab

    -- arbitrarily pick the first terminal to focus
    vim.fn.win_gotoid(open_terminals[1])
  else
    vim.cmd([[vertical topleft Ttoggle]])
  end
end

---Open a REPL terminal that runs `repl_cmd` and begin editing the REPL input buffer `".repl." .. repl_extension`.
---The terminal is placed top-left if any neoterm instances are open, and vertically leftmost otherwise.
---`:write`ing to the RPEL file will send the contents to the repl. The extension is used for file type detection.
---
---@class EditReplOptions
---@field save fun(buffer_id: number) callback to override the default save. It is passed the buffer id of the REPL.
---
---@see setup_vimtest()
---@param repl_cmd string a command to start a REPL in a neoterm instance
---@param repl_extension string the name of the file to use for input commands to the REPL
---@param options? EditReplOptions additional REPL options
---* *save* a callback to override the default save, which sends the contents
--- of the repl input buffer to the repl. The callback is passed a single
--- argument, the buffer id of the REPL.
function M.edit_repl(repl_cmd, repl_extension, options)
  local config = vim.tbl_deep_extend('force', {
    save = function()
      vim.cmd('TREPLSendFile')
    end
  }, options or {})

  local repl_file = '.repl.' .. repl_extension

  local starting_window = vim.api.nvim_get_current_win()
  vim.cmd('edit ' .. repl_file)
  vim.b.repl_save = config.save

  local needs_repl_terminal = true

  -- first check to see if there's an existing valid REPL to use
  local repl_instance_id = vim.g.neoterm and vim.g.neoterm.repl and vim.g.neoterm.repl.instance_id
  if repl_instance_id then
    local repl_instance = vim.g.neoterm.instances[repl_instance_id]
    local repl_buffer_id = repl_instance.buffer_id
    local win_id = vim.fn.bufwinid(repl_buffer_id)
    log.debug('checking old repl instance ', { repl = repl_instance_id, buf = repl_buffer_id, win = win_id })
    local buffer_valid = vim.api.nvim_buf_is_valid(repl_buffer_id)
    if buffer_valid then
      log.debug('reusing old repl instance')
      needs_repl_terminal = false
      local has_window = win_id and win_id ~= -1
      if not has_window then
        -- there's a valid repl in a buffer, but that buffer isn't in a window anywhere
        vim.cmd('Ttoggle ' .. repl_instance_id)
      end
    end
  end

  if needs_repl_terminal then
    -- create the REPL buffer
    local open_terminals = get_neoterm_window_ids()
    if #open_terminals > 0 then
      -- we already have a terminal, don't use that one for a REPL, instead
      -- open one above it
      vim.cmd([[
        " Create a new neoterm window in the top-left
        100wincmd h
        100wincmd k
        above new
        Tnew
        normal G
      ]])
    else
      -- if we have no open terminals, create one vertically on the left
      vim.cmd([[
        vertical topleft Tnew
        normal G
      ]])
    end

    -- start the REPL
    vim.cmd('T ' .. repl_cmd)
    vim.cmd('TREPLSetTerm ' .. vim.g.neoterm.last_id)
  end

  vim.api.nvim_set_current_win(starting_window)
  vim.cmd('stopinsert')
end

--TODO: guess based on filetype?
---Set up a REPL buffer with associated REPL
---
---Takes no parameters, but prompts the user for all inputs.
function M.edit_generic_repl()
  local repl_cmd = nil
  local repl_extension = nil

  vim.ui.input({ prompt = 'REPL command (e.g. node) > ', default = 'node' },
    function(input) repl_cmd = input end)

  vim.ui.input({ prompt = 'REPL input file extension (e.g. js) > ', default = 'js' },
    function(input) repl_extension = input end)

  if not repl_cmd then error('No REPL command given. Please specify a commnad to start the REPL.') end

  if not repl_extension then
    error(
      'No extension given. Please specify an extension (to trigger filetype) for your REPL input buffer')
  end

  M.edit_repl(repl_cmd, repl_extension)

  local suggested_keymap = [[vim.api.nvim_set_keymap('n', '<leader>re', function() require('hjdivad').edit_repl(']] ..
      repl_cmd .. [[', ']] .. repl_extension .. [[') end]]
  vim.notify([[To skip inputs next time, consider adding `]] .. suggested_keymap ..
    [[` to .vimrc.lua]], vim.log.levels.INFO, {})
end

local function setup_repls()
  table.insert(autocmd_ids, vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '.repl.*',
    callback = function()
      log.trace('[.repl] BufWritePost')
      local repl_instance_id = vim.g.neoterm.repl.instance_id
      local repl_instance = vim.g.neoterm.instances[repl_instance_id]
      local repl_buffer_id = repl_instance.buffer_id
      vim.b.repl_save(repl_buffer_id)
    end
  }))
end

local function create_user_commands()
  vim.api.nvim_create_user_command('HiResize', function() resize_terminal_windows { all = true } end,
    { desc = 'Resize windows, ensuring a fixed-width terminal has appropriate width' })
end

---Private API exported for testing
---
---@private
local function teardown()
  for _, id in ipairs(autocmd_ids) do
    vim.api.nvim_del_autocmd(id)
  end
  autocmd_ids = {}
  saved_vim_options = {}
end

M._teardown = teardown

---Main entry point for setting up neoterm & REPL editing
---
function M.setup(options)
  local config = vim.tbl_deep_extend('force', {
    mappings = false
  }, options or {})

  vim.g.neoterm_autoinsert = 1
  vim.g.neoterm_auto_repl_cmd = 0

  -- disable automapping from neoterm
  vim.g.neoterm_automap_keys = '😡😡STUPID_PLUGIN_DO_NOT_AUTOMAP'

  setup_terminal(config)
  setup_repls()
  create_user_commands()
end

return M
