describe("neotree", function()
  local assert = require("luassert")

  -- Mock modules BEFORE requiring neotree
  local mock_git = {
    merge_base = function()
      return "abc123"
    end,
    set_gs_to_merge_base = function() end,
  }

  local mock_gitsigns = {
    diffthis = function() end,
  }

  local mock_map_stack = {}
  mock_map_stack = {
    push = function(cb)
      -- Store the callback for testing
      mock_map_stack.last_callback = cb
    end,
    pop = function() end,
  }

  local function setup_mocks()
    package.loaded["hjdivad.git"] = mock_git
    package.loaded["gitsigns"] = mock_gitsigns
    package.loaded["hjdivad.map_stack"] = mock_map_stack
  end

  -- Set up mocks before requiring the module
  setup_mocks()

  ---@type NeotreeGitChanges
  local neotree = require("hjdivad.neotree")

  before_each(function()
    -- Reset mocks for each test
    mock_gitsigns.diffthis = function() end
    mock_map_stack.last_callback = nil
    mock_map_stack.push = function(cb)
      mock_map_stack.last_callback = cb
    end
    mock_map_stack.pop = function() end

    -- Reset state
    neotree.git_changes_tab = nil
    neotree.file_list = {}
    neotree.current_file_index = 1
    neotree.current_map_stack = nil
  end)

  describe("tab_management", function()
    it("should create a new tab when none exists", function()
      local initial_tabs = #vim.api.nvim_list_tabpages()

      neotree.switch_to_git_changes_tab()

      local final_tabs = #vim.api.nvim_list_tabpages()
      assert.equals(initial_tabs + 1, final_tabs)
      assert.is_not_nil(neotree.git_changes_tab)
    end)

    it("should switch to existing tab if it still has neotree", function()
      -- Create initial tab
      neotree.switch_to_git_changes_tab()
      local first_tab = neotree.git_changes_tab

      -- Create another tab and switch away
      vim.cmd("tabnew")

      -- Mock vim.api functions to simulate first tab having neotree
      local original_list_wins = vim.api.nvim_tabpage_list_wins
      local original_win_get_buf = vim.api.nvim_win_get_buf
      local original_buf_get_name = vim.api.nvim_buf_get_name
      local original_set_tabpage = vim.api.nvim_set_current_tabpage

      vim.api.nvim_tabpage_list_wins = function(tabnr)
        if tabnr == first_tab then
          return { 1 } -- Mock window in first tab
        else
          return { 2 } -- Mock window in other tab
        end
      end

      vim.api.nvim_win_get_buf = function(winid)
        return winid -- Simple mapping
      end

      vim.api.nvim_buf_get_name = function(bufnr)
        if bufnr == 1 then
          return "neo-tree filesystem [1]" -- First tab has neotree
        else
          return "some_file.txt" -- Other tab doesn't
        end
      end

      vim.api.nvim_set_current_tabpage = function(tabnr)
        -- Mock successful tab switch
      end

      -- Switch back to git changes - should reuse existing tab
      neotree.switch_to_git_changes_tab()

      -- Should switch to existing tab, not create new one
      assert.equals(first_tab, neotree.git_changes_tab)

      -- Restore original functions
      vim.api.nvim_tabpage_list_wins = original_list_wins
      vim.api.nvim_win_get_buf = original_win_get_buf
      vim.api.nvim_buf_get_name = original_buf_get_name
      vim.api.nvim_set_current_tabpage = original_set_tabpage
    end)

    it("should create new tab if tracked tab was closed", function()
      -- Set a non-existent tab reference
      neotree.git_changes_tab = 999

      local initial_tabs = #vim.api.nvim_list_tabpages()
      neotree.switch_to_git_changes_tab()

      -- Should create new tab and update reference
      local final_tabs = #vim.api.nvim_list_tabpages()
      assert.equals(initial_tabs + 1, final_tabs)
      assert.is_not_nil(neotree.git_changes_tab)
      assert.not_equals(999, neotree.git_changes_tab)
    end)
  end)

  describe("file_navigation", function()
    it("should navigate to next file in list", function()
      neotree.file_list = { "file1.txt", "file2.txt", "file3.txt" }
      neotree.current_file_index = 1

      -- Mock open_file_for_diff_by_path
      local opened_file = nil
      neotree.open_file_for_diff_by_path = function(filepath)
        opened_file = filepath
      end

      neotree.navigate_to_file("next")

      assert.equals(2, neotree.current_file_index)
      assert.equals("file2.txt", opened_file)
    end)

    it("should navigate to previous file in list", function()
      neotree.file_list = { "file1.txt", "file2.txt", "file3.txt" }
      neotree.current_file_index = 2

      -- Mock open_file_for_diff_by_path
      local opened_file = nil
      neotree.open_file_for_diff_by_path = function(filepath)
        opened_file = filepath
      end

      neotree.navigate_to_file("prev")

      assert.equals(1, neotree.current_file_index)
      assert.equals("file1.txt", opened_file)
    end)

    it("should loop to beginning when navigating past end", function()
      neotree.file_list = { "file1.txt", "file2.txt", "file3.txt" }
      neotree.current_file_index = 3

      -- Mock open_file_for_diff_by_path
      local opened_file = nil
      neotree.open_file_for_diff_by_path = function(filepath)
        opened_file = filepath
      end

      neotree.navigate_to_file("next")

      assert.equals(1, neotree.current_file_index)
      assert.equals("file1.txt", opened_file)
    end)

    it("should loop to end when navigating before beginning", function()
      neotree.file_list = { "file1.txt", "file2.txt", "file3.txt" }
      neotree.current_file_index = 1

      -- Mock open_file_for_diff_by_path
      local opened_file = nil
      neotree.open_file_for_diff_by_path = function(filepath)
        opened_file = filepath
      end

      neotree.navigate_to_file("prev")

      assert.equals(3, neotree.current_file_index)
      assert.equals("file3.txt", opened_file)
    end)

    it("should handle empty file list gracefully", function()
      neotree.file_list = {}

      -- Should not error
      neotree.navigate_to_file("next")
      neotree.navigate_to_file("prev")
    end)
  end)

  describe("map_stack_integration", function()
    it("should have navigation functions", function()
      -- Test that the navigation functions exist
      assert.is_function(neotree.navigate_to_file)
      assert.is_function(neotree.open_file_for_diff_by_path)

      -- Test basic state management
      neotree.file_list = { "file1.txt", "file2.txt" }
      neotree.current_file_index = 1

      -- Test navigate_to_file with mock
      local opened_file = nil
      neotree.open_file_for_diff_by_path = function(filepath)
        opened_file = filepath
      end

      neotree.navigate_to_file("next")
      assert.equals(2, neotree.current_file_index)
      assert.equals("file2.txt", opened_file)
    end)

    it("should clean up map stack when showing new git changes tree", function()
      -- Setup existing map stack
      neotree.current_map_stack = true

      -- Mock vim.cmd and git functions
      vim.cmd = function() end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end
      vim.api.nvim_list_tabpages = function()
        return { 1 }
      end

      local pop_called = false
      mock_map_stack.pop = function()
        pop_called = true
      end

      neotree.show_git_changes_tree()

      assert.is_true(pop_called)
      assert.is_nil(neotree.current_map_stack)
    end)
  end)

  describe("open_file_for_diff", function()
    local function make_node(id, type_, path_, children)
      local node = {
        id = id,
        type = type_,
        path = path_,
        _children = children or {},
      }
      function node:get_id()
        return self.id
      end
      function node:has_children()
        return self._children and #self._children > 0
      end
      return node
    end

    local function make_state(selected_node, root_node)
      local by_id = {}
      local function index(node)
        by_id[node.id] = node
        if node._children then
          for _, c in ipairs(node._children) do
            index(c)
          end
        end
      end
      index(root_node)

      return {
        tree = {
          get_node = function()
            return selected_node
          end,
          get_nodes = function(_, parent_id)
            if parent_id == nil then
              return { root_node }
            end
            local n = by_id[parent_id]
            return (n and n._children) or {}
          end,
        },
      }
    end

    it("builds file list, sets index, and opens selected file", function()
      local file1 = make_node("f1", "file", "/tmp/a.txt")
      local file2 = make_node("f2", "file", "/tmp/b.txt")
      local dir = make_node("d1", "directory", "/tmp/dir", { file2 })
      local root = make_node("root", "directory", "/", { file1, dir })

      local opened
      neotree.open_file_for_diff_by_path = function(p)
        opened = p
      end

      -- select file2 (nested)
      local state = make_state(file2, root)
      neotree.file_list = {}
      neotree.current_file_index = 1

      neotree.open_file_for_diff(state)

      assert.same({ "/tmp/a.txt", "/tmp/b.txt" }, neotree.file_list)
      assert.equals(2, neotree.current_file_index)
      assert.equals("/tmp/b.txt", opened)
    end)

    it("no-ops when selected node is not a file", function()
      local file1 = make_node("f1", "file", "/tmp/a.txt")
      local dir = make_node("d1", "directory", "/tmp/dir", { file1 })
      local root = make_node("root", "directory", "/", { dir })

      local called = false
      neotree.open_file_for_diff_by_path = function()
        called = true
      end

      neotree.file_list = { "keep" }
      neotree.current_file_index = 7

      local state = make_state(dir, root)
      neotree.open_file_for_diff(state)

      assert.is_false(called)
      assert.same({ "keep" }, neotree.file_list)
      assert.equals(7, neotree.current_file_index)
    end)
  end)

  describe("show_git_changes_tree", function()
    it("invokes Neotree with merge base and updates gitsigns base", function()
      -- avoid tab/window creation in this test
      local original_switch = neotree.switch_to_git_changes_tab
      neotree.switch_to_git_changes_tab = function() end

      local cmds = {}
      local original_cmd = vim.cmd
      vim.cmd = function(c)
        table.insert(cmds, c)
      end

      local called_set = false
      local set_arg
      package.loaded["hjdivad.git"].set_gs_to_merge_base = function(arg)
        called_set = true
        set_arg = arg
      end

      neotree.show_git_changes_tree()

      -- assert Neotree command used abc123 from mock merge_base()
      local found = false
      for _, c in ipairs(cmds) do
        if c == "Neotree git_status git_base=abc123 reveal=true" then
          found = true
          break
        end
      end
      assert.is_true(found)
      assert.is_true(called_set)
      assert.equals("abc123", set_arg)

      -- restore
      vim.cmd = original_cmd
      neotree.switch_to_git_changes_tab = original_switch
    end)
  end)
end)
