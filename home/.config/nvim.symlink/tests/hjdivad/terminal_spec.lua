local terminal = require('hjdivad/terminal')
local util = require('hjdivad/utils')

local ptest = require('plenary/async/tests')
local test_helper = require('hjdivad/test_helper')

local a = {
  describe = ptest.describe,
  it = ptest.it,
  before_each = ptest.before_each,
  after_each = ptest.after_each,
}
local get_terminal_expected_width = terminal._get_terminal_expected_width

test_helper.setup()

vim.cmd('packadd neoterm')
describe('hjdivad/terminal', function()
  local columns = vim.o.columns

  after_each(function()
    vim.o.columns = columns
  end)

  describe('.get_terminal_expected_width', function()
    it('gives a large width for large displays', function()
      vim.o.columns = 220
      assert.equals(120, get_terminal_expected_width())
    end)

    it('gives a smaller width for smaller displays', function()
      assert.equals(79, get_terminal_expected_width())
    end)
  end)

  describe('.setup', function()
    before_each(function()
      test_helper.health_check()
      -- start all tests in a new window to make sure we don't inherit window
      -- options from a prior test
      vim.cmd('wincmd n')
    end)

    after_each(function()
      terminal._teardown()
      test_helper.teardown()
    end)

    it('ensures terminals have reasonable options', function()
      terminal.setup {}

      vim.cmd('terminal')
      assert.matches('^term://', vim.fn.bufname(), 'test is in a buffer')

      assert.equals(true, vim.o.winfixwidth, 'terminals fixed width')
      assert.equals(false, vim.o.number, 'terminals no number line')
      assert.equals(false, vim.o.relativenumber, 'terminals no relative numbers')
      assert.equals(false, vim.o.spell, "terminals don't spellcheck")
    end)

    it('resets window options when the window switches from a terminal', function()
      terminal.setup {}

      vim.o.winfixwidth = false
      vim.wo.number = true
      vim.o.relativenumber = true

      vim.cmd('terminal')
      assert.matches('^term://', vim.fn.bufname(), 'test is in a buffer')

      vim.cmd('edit /tmp/test.md')

      assert.equals(false, vim.o.winfixwidth, 'no fixed width')
      assert.equals(true, vim.o.number, 'number line')
      assert.equals(true, vim.o.relativenumber, 'relative numbers')
    end)

    it('restores window options when a window enters a terminal', function()
      terminal.setup {}

      vim.o.winfixwidth = false
      vim.wo.number = true
      vim.o.relativenumber = true

      vim.cmd('terminal')
      assert.matches('^term://', vim.fn.bufname(), 'test is in a buffer')

      local bufn = vim.fn.bufnr()
      vim.cmd('edit! /tmp/test.md')
      assert.equals(false, vim.o.winfixwidth, 'no fixed width')

      vim.api.nvim_win_set_buf(0, bufn)
      assert.matches('^term://', vim.fn.bufname(), 'test is in a buffer')

      assert.equals(true, vim.o.winfixwidth, 'terminals fixed width')
      assert.equals(false, vim.o.number, 'terminals no number line')
      assert.equals(false, vim.o.relativenumber, 'terminals no relative numbers')
      assert.equals(false, vim.o.spell, "terminals don't spellcheck")
    end)

    it('does not create mappings by default ', function()
      vim.cmd('terminal')
      local t_keymaps = vim.api.nvim_get_keymap('t')
      local n_keymaps = vim.api.nvim_buf_get_keymap(0, 'n')
      vim.cmd('bwipeout!')

      terminal.setup {}

      vim.cmd('terminal')
      local updated_t_keymaps = vim.api.nvim_get_keymap('t')
      local updated_n_keymaps = vim.api.nvim_buf_get_keymap(0, 'n')

      assert.equals(#t_keymaps, #updated_t_keymaps, 'by default no terminal keymaps are created')
      assert.equals(#n_keymaps, #updated_n_keymaps, 'by default no terminal-buffer normal keymaps are created')
    end)

    it('creates terminal mappings for window motions', function()
      vim.cmd('terminal')
      local t_keymaps = vim.api.nvim_get_keymap('t')
      local n_keymaps = vim.api.nvim_buf_get_keymap(0, 'n')
      vim.cmd('bwipeout!')
      assert.matches('^$', vim.fn.bufname(), 'back to [no name]')

      terminal.setup { mappings = true }

      vim.cmd('terminal')
      assert.matches('^term://', vim.fn.bufname(), 'test is in a buffer')
      local updated_t_keymaps = vim.api.nvim_get_keymap('t')

      assert.equals(12, #updated_t_keymaps - #t_keymaps, 'terminal keymaps installed')
      assert.has_keymap('t', '<c-w>h')
      assert.has_keymap('t', '<c-w><c-h>')
      assert.has_keymap('t', '<c-w>j')
      -- This keymap registeres (see :tmap) but doesn't seem to show up in
      -- vim.api.nvim_get_keymap('t')
      -- assert.has_keymap('t', '<c-w><c-j>')
      assert.has_keymap('t', '<c-w>k')
      assert.has_keymap('t', '<c-w><c-k>')
      assert.has_keymap('t', '<c-w>l')
      assert.has_keymap('t', '<c-w><c-l>')
      assert.has_keymap('t', '<c-w>c')
      assert.has_keymap('t', '<c-w><c-c>')
      assert.has_keymap('t', '<c-w>n')
      assert.has_keymap('t', '<c-w><c-n>')

      local updated_n_keymaps = vim.api.nvim_buf_get_keymap(0, 'n')
      assert.equals(2, #updated_n_keymaps - #n_keymaps, 'terminal-buffer normal keymaps installed')
      assert.has_buf_keymap(0, 'n', '<c-w>n')
      assert.has_buf_keymap(0, 'n', '<c-w><c-n>')
    end)

    it('initializes terminals to a reasonable size for small displays', function()
      terminal.setup {}

      vim.o.columns = 200
      vim.cmd('wincmd v')
      vim.cmd('terminal')

      assert.equals(79, vim.api.nvim_win_get_width(0))
    end)

    it('initializes terminals to a reasonable size for large displays', function()
      terminal.setup {}

      vim.o.columns = 220
      vim.cmd('wincmd v')
      vim.cmd('terminal')

      assert.equals(120, vim.api.nvim_win_get_width(0))
    end)
  end)
end)

a.describe('.edit_repl', function()
  local shell = vim.g.neoterm_shell
  local repl_wait = 50

  a.before_each(function()
    test_helper.health_check()
    vim.g.neoterm_shell = '/bin/sh'
    terminal.setup {}
  end)

  a.after_each(function()
    vim.g.neoterm_shell = shell
    test_helper.teardown()
    terminal._teardown()
  end)

  ---Assert that the REPL has been set up as expected.
  ---
  ---Note that there are going to be some differences in behaviour between osx
  ---& linux so some of the matching is fuzzy (e.g. checking for a cat$ prompt
  ---in the first few lines rather than knowing which specific line it's on)
  local function assert_repl_state()
    test_helper.wait(repl_wait)
    assert.equals(2, #vim.api.nvim_list_wins(), '2 windows open')
    assert.equals(vim.fn.bufname(), '.repl.txt', 'repl buffer is open')

    local tl_win = test_helper.find_winid_top_left()
    assert.Not.equal(nil, tl_win, 'found the topleft window')

    local tl_buf = vim.api.nvim_win_get_buf(tl_win)
    -- terminal is opened in the top left
    assert.matches('^term://', vim.fn.bufname(tl_buf))

    -- terminal has started the REPL command
    local first_lines = vim.api.nvim_buf_get_lines(tl_buf, 0, 2, false)
    local cat_prompt_lines = vim.tbl_filter(function(l) return l:match('%$ cat$') end, first_lines)
    assert.equals(#cat_prompt_lines, 1, 'terminal has one cat prompt')
    --
    vim.api.nvim_buf_set_lines(0, 0, 999, false, { 'hello' })
    vim.cmd('silent write')
    test_helper.wait(repl_wait)

    local all_lines = vim.api.nvim_buf_get_lines(tl_buf, 1, 999, false)
    local lines = vim.tbl_filter(function(l) return #l > 0 end, all_lines)
    assert.same({ 'hello', 'hello' }, { unpack(lines, #lines - 1, #lines) })
  end

  a.it('sets up a REPL initially', function()
    terminal.edit_repl('cat', 'txt')
    assert_repl_state()
  end)

  a.it('restores a REPL buffer starting from the REPL window', function()
    terminal.edit_repl('cat', 'txt')
    assert_repl_state()

    vim.api.nvim_win_close(0, false)
    assert.equals(1, #vim.api.nvim_list_wins(), '1 window open')
    assert.matches('^term://', vim.fn.bufname(), 'REPL open, REPL buffer closed')

    terminal.edit_repl('cat', 'txt')
    assert_repl_state()
  end)

  a.it('restore the REPL when the REPL buffer is visible', function()
    terminal.edit_repl('cat', 'txt')
    assert_repl_state()

    local windows = vim.api.nvim_list_wins()
    local other_win = util.tbl_find(function(win_id)
      return win_id ~= vim.api.nvim_get_current_win()
    end, windows)

    vim.api.nvim_win_close(other_win, false)
    assert.equals(1, #vim.api.nvim_list_wins(), '1 window open')
    assert.equals('.repl.txt', vim.fn.bufname(), 'REPL open, REPL buffer closed')

    terminal.edit_repl('cat', 'txt')
    assert_repl_state()
  end)

  a.it('restores the REPL and buffer when neither is visible', function()
    terminal.edit_repl('cat', 'txt')
    assert_repl_state()

    local windows = vim.api.nvim_list_wins()

    vim.cmd('wincmd n')
    for _, win_id in ipairs(windows) do
      vim.api.nvim_win_close(win_id, false)
    end

    assert.equals('', vim.fn.bufname(), 'both REPL and input buffer closed')
    terminal.edit_repl('cat', 'txt')
    assert_repl_state()
  end)

  a.it('allows custom save handlers', function()
    terminal.edit_repl('cat', 'txt', { save = function(repl_buffer_id)
      local channel = vim.api.nvim_buf_get_option(repl_buffer_id, 'channel')
      vim.fn.chansend(channel, { 'neat', 'or so it is said', '' })
    end })
    test_helper.wait(repl_wait)

    vim.api.nvim_buf_set_lines(0, 0, 999, false, { 'hello' })
    vim.cmd('silent write')
    test_helper.wait(repl_wait)

    local tl_win = test_helper.find_winid_top_left()
    assert.Not.equal(nil, tl_win, 'found the topleft window')

    local tl_buf = vim.api.nvim_win_get_buf(tl_win)
    local all_lines = vim.api.nvim_buf_get_lines(tl_buf, 1, 999, false)
    local lines = vim.tbl_filter(function(l) return #l > 0 end, all_lines)

    assert.same({ 'neat', 'or so it is said', 'neat', 'or so it is said' }, { unpack(lines, #lines - 3, #lines) })
  end)

  --TODO: edit_generic_repl
end)
