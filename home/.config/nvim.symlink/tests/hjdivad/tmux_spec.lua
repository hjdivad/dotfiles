local stub = require('luassert/stub')

local utils = require('hjdivad/utils')
local tmux = require('hjdivad/tmux')

describe('_get_tmux_panes', function()
  after_each(function()
    local stubs = { utils.get_os_command_output, vim.api.nvim_command, vim.api.nvim_err_writeln }
    for _, stub_fn in ipairs(stubs) do
      if stub_fn and type(stub_fn) ~= 'function' then
        stub_fn:revert()
      end
    end
  end)

  describe('_get_tmux_panes', function()
    it('returns tmux panes as a list of dictionaries', function()
      stub(utils, 'get_os_command_output')
      utils.get_os_command_output.returns({
        '%6⊱dotfiles⊱dotfiles',
        '%8⊱common.nvim⊱dotfiles',
        '%3⊱nyx⊱scratch-misc',
        '%0⊱todos⊱todos',
        '%1⊱reference⊱todos',
        '%2⊱journal⊱todos',
      })
      local panes = tmux._get_tmux_panes()
      assert.stub(utils.get_os_command_output).was_called_with({
        'tmux', 'list-panes', '-a', '-F', '#{pane_id}⊱#{window_name}⊱#{session_name}'
      })
      assert.same({
        {
          pane_id = '%6',
          session_name = 'dotfiles',
          window_name = 'dotfiles',
        },
        {
          pane_id = '%8',
          session_name = 'dotfiles',
          window_name = 'common.nvim',
        },
        {
          pane_id = '%3',
          session_name = 'scratch-misc',
          window_name = 'nyx',
        },
        {
          pane_id = '%0',
          session_name = 'todos',
          window_name = 'todos',
        },
        {
          pane_id = '%1',
          session_name = 'todos',
          window_name = 'reference',
        },
        {
          pane_id = '%2',
          session_name = 'todos',
          window_name = 'journal',
        },
      }, panes, 'panes are parsed correctly')
    end)
  end)

  describe('goto_tmux_session', function()
    before_each(function()
      stub(utils, 'get_os_command_output')
      utils.get_os_command_output.returns({
        '%6⊱dotfiles⊱dotfiles',
        '%8⊱common.nvim⊱dotfiles',
        '%3⊱nyx⊱scratch-misc',
        '%0⊱todos⊱todos',
        '%1⊱reference⊱todos',
        '%2⊱journal⊱todos',
      })

      stub(vim.api, 'nvim_command')
      stub(vim.api, 'nvim_err_writeln')
    end)

    it('switches client when the session + window match', function()
      tmux.goto_tmux_session('todos', 'todos')
      assert.stub(vim.api.nvim_command).was_called_with([[silent !tmux switch-client -t \\%0]])

      tmux.goto_tmux_session('dotfiles', 'common.nvim')
      assert.stub(vim.api.nvim_command).was_called_with([[silent !tmux switch-client -t \\%8]])

      assert.stub(vim.api.nvim_err_writeln).was_not_called()
    end)

    it('errors if there is no match', function()
      tmux.goto_tmux_session('no_such_session', 'no_such_window')
      assert.stub(vim.api.nvim_err_writeln).was_called_with('Cannot find tmux pane "no_such_session:no_such_window"')
      assert.stub(vim.api.nvim_command).was_not_called()
    end)

    it('errors if only the session matches', function()
      tmux.goto_tmux_session('todos', 'no_such_window')
      assert.stub(vim.api.nvim_err_writeln).was_called_with('Cannot find tmux pane "todos:no_such_window"')
      assert.stub(vim.api.nvim_command).was_not_called()
    end)

    it('errors if only the window matches', function()
      tmux.goto_tmux_session('no_such_session', 'todos')
      assert.stub(vim.api.nvim_err_writeln).was_called_with('Cannot find tmux pane "no_such_session:todos"')
      assert.stub(vim.api.nvim_command).was_not_called()
    end)
  end)
end)
