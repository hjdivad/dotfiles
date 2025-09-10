local M = {}

---Check if a git ref exists
---@param ref string The git ref to check (e.g., "origin/master")
---@return boolean
local function ref_exists(ref)
  local _ = vim.fn.system("git rev-parse --verify " .. ref .. " 2>/dev/null")
  return vim.v.shell_error == 0
end

---Get the merge base of HEAD and the upstream branch
---@return string|nil The merge base commit hash, or nil if not found
function M.merge_base()
  -- Check if we're in a git repository
  local _ = vim.fn.system("git rev-parse --git-dir 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Try upstream branches in order of preference
  local upstream_branches = { "origin/master", "origin/HEAD", "origin/main" }

  for _, upstream in ipairs(upstream_branches) do
    if ref_exists(upstream) then
      local merge_base = vim.fn.system("git merge-base HEAD " .. upstream .. " 2>/dev/null")
      if vim.v.shell_error == 0 then
        -- Strip whitespace and return the commit hash
        return vim.trim(merge_base)
      end
    end
  end

  return nil
end

function M.set_gs_to_merge_base(commit)
  if commit == nil then
    commit = M.merge_base()
  end
  local gs = require("gitsigns")
  gs.change_base(commit, true)
end

return M

