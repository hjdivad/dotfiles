---@class NeotreeGitChanges
local M = {}

local git = require("hjdivad.git")
local map_stack = require("hjdivad.map_stack")

-- State management
M.git_changes_tab = nil -- Track dedicated tab number
M.file_list = {} -- Track files for navigation
M.current_file_index = 1 -- Current file position
M.current_map_stack = nil -- Track current map stack

---Check if a tab exists and contains a Neo-tree window
---@param tabnr number The tab number to check
---@return boolean
local function tab_has_neotree(tabnr)
  local tabwins = vim.api.nvim_tabpage_list_wins(tabnr)
  for _, winid in ipairs(tabwins) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match("neo%-tree") then
      return true
    end
  end
  return false
end

---Get the Neo-tree window in the current tab
---@return number|nil winid Window ID of Neo-tree, or nil if not found
local function get_neotree_window()
  local tabwins = vim.api.nvim_tabpage_list_wins(0)
  for _, winid in ipairs(tabwins) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match("neo%-tree") then
      return winid
    end
  end
  return nil
end

---Extract file list from Neo-tree state for navigation
---@param state table Neo-tree state
---@return string[] List of file paths
local function extract_file_list(state)
  local files = {}
  local function traverse_node(node)
    if node.type == "file" then
      table.insert(files, node.path)
    elseif node:has_children() then
      for _, child in ipairs(state.tree:get_nodes(node:get_id())) do
        traverse_node(child)
      end
    end
  end

  -- Get root node and traverse
  local root = state.tree:get_nodes()[1]
  if root then
    traverse_node(root)
  end

  return files
end

---Find the index of current file in the file list
---@param filepath string The file path to find
---@param file_list string[] The list of files
---@return number Index of the file (1-based), or 1 if not found
local function find_file_index(filepath, file_list)
  for i, file in ipairs(file_list) do
    if file == filepath then
      return i
    end
  end
  return 1
end

---Navigate to a file by direction
---@param direction "next"|"prev" Direction to navigate
function M.navigate_to_file(direction)
  if #M.file_list == 0 then
    return
  end

  if direction == "next" then
    M.current_file_index = M.current_file_index + 1
    if M.current_file_index > #M.file_list then
      M.current_file_index = 1 -- Loop to beginning
    end
  elseif direction == "prev" then
    M.current_file_index = M.current_file_index - 1
    if M.current_file_index < 1 then
      M.current_file_index = #M.file_list -- Loop to end
    end
  end

  local filepath = M.file_list[M.current_file_index]
  if filepath then
    M.open_file_for_diff_by_path(filepath)
  end
end

---Close all windows except neotree and the specified file window
---@param neotree_win number The neotree window ID to keep
---@param file_win number The file window ID to keep
local function close_other_windows(neotree_win, file_win)
  local tabwins = vim.api.nvim_tabpage_list_wins(0)
  for _, winid in ipairs(tabwins) do
    if winid ~= neotree_win and winid ~= file_win then
      --FIXME: this sometimes errors when navigating with <c-j>, <c-k> Unclear
      --why.  Probably need some debugging with (win, buf, bufname) and/or
      --printing winids on winopen/winclose or whatever the events are
      pcall(vim.api.nvim_win_close, winid, false)
    end
  end
end


---Run gitsigns.diffthis()
---
---The whole function tries to do this after gitsigns has attached.  This can
---take a surprisingly long time and seems to correlate with LSP startup time.
---
---If the buffer is already open then this function is a convoluted way of running
---```lua
--- require('gitsigns').diffthis()
---```
function M._gitsigns_diffthis()
  local file_win = vim.api.nvim_get_current_win()

  -- Wait until gitsigns attaches to the buffer, then diff. Try briefly.
  vim.api.nvim_set_current_win(file_win)
  local bufnr = vim.api.nvim_win_get_buf(file_win)
  local tries = 0
  local function is_gitsigns_ready()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return false
    end
    local b = vim.b[bufnr]
    return b and (b.gitsigns_status_dict ~= nil or b.gitsigns_head ~= nil)
  end
  local function try_diff()
    if not vim.api.nvim_win_is_valid(file_win) or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if is_gitsigns_ready() then
      vim.api.nvim_set_current_win(file_win)
      pcall(function()
        require("gitsigns").diffthis()
      end)
      return
    end
    if tries == 0 then
      -- Proactively try to attach once
      pcall(function()
        require("gitsigns").attach(bufnr)
      end)
    end
    if tries < 15 then
      tries = tries + 1
      vim.defer_fn(try_diff, 20)
    end
  end
  vim.schedule(try_diff)
end

---Open a file for diffing by path
---@param filepath string The file path to open
function M.open_file_for_diff_by_path(filepath)
  local neotree_win = get_neotree_window()
  if not neotree_win then
    return
  end

  -- Move to the neotree window
  vim.api.nvim_set_current_win(neotree_win)

  -- Split to the right and open the file (this preserves neotree sizing)
  vim.cmd("rightbelow vsplit")

  local file_win = vim.api.nvim_get_current_win()
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  close_other_windows(neotree_win, file_win)

  M._gitsigns_diffthis()

  --FIXME: These mappings should be buffer-local
  -- I can't just add buffer=true because the keyamps are behind the M.current_map_stack flag.
  -- map_stack might need another feature 🤔
  --
  -- Setup custom keybindings if not already done
  if not M.current_map_stack then
    M.current_map_stack = true
    map_stack.push(function(keymap)
      keymap.set("n", "<C-j>", function()
        M.navigate_to_file("next")
      end, { desc = "Next changed file" })
      keymap.set("n", "<C-k>", function()
        M.navigate_to_file("prev")
      end, { desc = "Previous changed file" })
    end)
  end
end

---Open a file for diffing from Neo-tree state
---@param state neotree.StateWithTree Neo-tree state
function M.open_file_for_diff(state)
  local node = state.tree:get_node()
  if not node or node.type ~= "file" then
    return
  end

  -- Update file list and current index
  M.file_list = extract_file_list(state)
  M.current_file_index = find_file_index(node.path, M.file_list)

  M.open_file_for_diff_by_path(node.path)
end

---Switch to or create the dedicated git changes tab
function M.switch_to_git_changes_tab()
  -- Check if we have a tracked tab and it still exists with Neo-tree
  if M.git_changes_tab then
    local tab_exists = false
    for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
      if tabnr == M.git_changes_tab and tab_has_neotree(tabnr) then
        tab_exists = true
        break
      end
    end

    if tab_exists then
      -- Switch to existing tab
      vim.api.nvim_set_current_tabpage(M.git_changes_tab)
      return
    else
      -- Tab was closed, clear our reference
      M.git_changes_tab = nil
    end
  end

  -- Create new tab
  vim.cmd("-tabnew")
  M.git_changes_tab = vim.api.nvim_get_current_tabpage()
end

---Show git changes tree in dedicated tab
---
---Set the merge base to $(git merge-base HEAD origin/master).
---When opening files, automatically run gitsigns.diffthis.
---
---Add <c-j>, <c-k> stacked bindings to navigate next/prev file for diffing.
---
---This gives a somewhat github-like experience.
function M.show_git_changes_tree()
  if M.current_map_stack then
    pcall(map_stack.pop) -- Use pcall to handle empty stack gracefully
    M.current_map_stack = nil
  end

  M.switch_to_git_changes_tab()

  local merge_base = git.merge_base()
  vim.cmd(string.format("Neotree git_status git_base=%s reveal=true", merge_base or "HEAD"))
  git.set_gs_to_merge_base(merge_base)
end

---Show git changes tree for HEAD commit only
---
---Shows only the changes in the HEAD commit itself (git diff HEAD~1 HEAD).
---When opening files, automatically run gitsigns.diffthis.
---Gitsigns base is NOT changed (keeps using origin/HEAD or whatever is configured).
---
---Add <c-j>, <c-k> stacked bindings to navigate next/prev file for diffing.
function M.show_git_changes_tree_head_only()
  if M.current_map_stack then
    pcall(map_stack.pop) -- Use pcall to handle empty stack gracefully
    M.current_map_stack = nil
  end

  M.switch_to_git_changes_tab()

  -- Show only changes in HEAD commit (compared to HEAD~1)
  vim.cmd("Neotree git_status git_base=HEAD~1 reveal=true")
  -- Note: We do NOT call git.set_gs_to_merge_base() here,
  -- so gitsigns keeps using its configured base (origin/HEAD)
end

return M
