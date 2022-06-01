local utils = require('hjdivad/utils')
local terminal = require('hjdivad/terminal')
local exrc = require('hjdivad/exrc')
local testing = require('hjdivad/testing')
local tmux = require('hjdivad/tmux')

local hi = utils.hjdivad_init


---Show the nvim-tree
---
---If the tree is not open, open it, otherwise switch to the tree's window.
---
---If the current buffer has a name, also find it in the tree.
---
---*note* finding files works poorly for those outside of `$CWD`
local function toggle_nvim_tree()
  -- TODO: make this work better when opening a file outside of <cwd>, as well as opening a file within <cwd> after nvimtree has cd-d outside
  --  i.e. NVIMTreeOpen dirname (file) or cwd + findfile
  -- TODO: make this work for NEW buffers (i.e buffers never saved)
  local buffer_name = vim.fn['bufname']()

  if buffer_name == '' then
    vim.cmd('NvimTreeOpen')
  else
    vim.cmd('NvimTreeFindFile')
  end
end

---Open a REPL terminal that runs `repl_cmd` and begin editing the REPL input buffer `".repl." .. repl_extension`.
---The terminal is placed top-left if any neoterm instances are open, and vertically leftmost otherwise.
---`:write`ing to the RPEL file will send the contents to the repl. The extension is used for file type detection.
---
---@see setup_vimtest()
---@param repl_cmd string a command to start a REPL in a neoterm instance
---@param repl_extension string the name of the file to use for input commands to the REPL
local function edit_repl(repl_cmd, repl_extension)
  local get_neoterm_window_ids = require('hjdivad/index').get_neoterm_window_ids
  -- TODO: make a toggle_repl that closes the repl windows if they're open
  local repl_file = '.repl.' .. repl_extension
  if not vim.g.neoterm.repl or not vim.g.neoterm.repl.instance_id then
    local starting_window = vim.api.nvim_get_current_win()
    -- create the REPL buffer
    local open_terminals = get_neoterm_window_ids()
    if #open_terminals > 0 then
      -- TODO: open the terminal if it's not visible
      -- if we have a terminal open on the left, create the REPL buffer in the topleft
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
    vim.cmd([[exe g:neoterm.last_id . 'T ]] .. repl_cmd .. "'")
    -- Set the new neoterm as the REPL terminal
    vim.cmd([[
      exe 'TREPLSetTerm ' . g:neoterm.last_id
    ]])

    -- return to our starting window to edit the repl input file
    vim.api.nvim_set_current_win(starting_window)
  end

  vim.cmd('edit ' .. repl_file)
  vim.cmd('stopinsert')
end

local function edit_generic_repl()
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

  edit_repl(repl_cmd, repl_extension)

  local suggested_keymap = [[vim.api.nvim_set_keymap('n', '<leader>re', function() require('hjdivad/index').edit_repl(']] .. repl_cmd .. [[', ']] .. repl_extension .. [[') end]]
  vim.notify([[To skip inputs next time, consider adding `]] .. suggested_keymap ..
    [[` to .vimrc.lua]], vim.log.levels.INFO, {})
end

local function setup_repls()
  vim.cmd([[
    augroup REPL
      autocmd!
      autocmd BufWritePre .repl.* exe 'TREPLSendFile'
    augroup end
  ]])
end

-- inform terminals that they are within an nvim instance
vim.env.NVIM_WRAPPER = 1

return {
  hjdivad_init = hi,
  setup_repls = setup_repls,
  run_exrc = exrc.run_exrc,
  setup_terminal = terminal.setup_terminal,


  -- TODO: move any of this to common.nvim?
  -- new exports
  toggle_nvim_tree = toggle_nvim_tree,

  toggle_terminal = terminal.toggle_terminal,
  resize_with_terminal = terminal.resize_with_terminal,

  goto_tmux_session = tmux.goto_tmux_session,

  edit_repl = edit_repl,
  edit_generic_repl = edit_generic_repl,

  debug_nearest = testing.debug_nearest,
  setup_vimtest = testing.setup_vimtest,
}
