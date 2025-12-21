local M = {}

local branch_prefix = "hjdivad/"

local function echo_err(msg)
  vim.api.nvim_echo({ { msg } }, true, { err = true })
end

local function trim_trailing_slash(path)
  return path:gsub("/+$", "")
end

local function derive_repo_rel(git_dir)
  local repo_root = vim.fn.fnamemodify(git_dir, ":h")
  local repo_root_abs = trim_trailing_slash(vim.fn.fnamemodify(repo_root, ":p"))
  local base_dir = trim_trailing_slash(vim.fn.fnamemodify(repo_root_abs, ":h:h:h"))

  if base_dir == "" or repo_root_abs:sub(1, #base_dir) ~= base_dir or #repo_root_abs <= (#base_dir + 1) then
    return nil, "unable to derive repo path from git dir " .. git_dir
  end

  local repo_rel = repo_root_abs:sub(#base_dir + 2)
  if repo_rel == "" then
    return nil, "derived empty repo relative path from " .. git_dir
  end

  return repo_rel
end

local function is_linked_worktree(git_dir_abs, worktree_root_abs)
  local main_git_dir_prefix = worktree_root_abs .. "/.git"
  if git_dir_abs:match("/%.git/worktrees/") then
    return true
  end

  return git_dir_abs:sub(1, #main_git_dir_prefix) ~= main_git_dir_prefix
end

local function work_branch_task(branch)
  return branch:match("^" .. branch_prefix .. "([^/]+)")
end

function M.StartAgentPrompt()
  local git_dir = vim.fn.system({ "git", "rev-parse", "--absolute-git-dir" })
  if vim.v.shell_error ~= 0 then
    echo_err("StartAgentPrompt: not inside a git repository")
    return
  end
  git_dir = vim.trim(git_dir)
  local git_dir_abs = trim_trailing_slash(vim.fn.fnamemodify(git_dir, ":p"))

  local worktree_root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 then
    echo_err("StartAgentPrompt: unable to read git worktree root")
    return
  end
  worktree_root = vim.trim(worktree_root)
  local worktree_root_abs = trim_trailing_slash(vim.fn.fnamemodify(worktree_root, ":p"))

  local branch = vim.fn.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" })
  if vim.v.shell_error ~= 0 then
    echo_err("StartAgentPrompt: unable to read current branch")
    return
  end
  branch = vim.trim(branch)

  local task = work_branch_task(branch)
  local linked_worktree = is_linked_worktree(git_dir_abs, worktree_root_abs)

  if linked_worktree and task == nil then
    echo_err("StartAgentPrompt: linked worktree must be on " .. branch_prefix .. "* (got " .. branch .. ")")
    return
  end

  local repo_rel
  if not linked_worktree then
    local err
    repo_rel, err = derive_repo_rel(git_dir_abs)
    if repo_rel == nil then
      echo_err("StartAgentPrompt: " .. err)
      return
    end
  end

  if task == nil then
    task = "task"
  end

  local prompt_dir
  if linked_worktree then
    prompt_dir = worktree_root_abs .. "/.uc"
  else
    prompt_dir = vim.fn.expand("$HOME/.local/state/uc/" .. repo_rel)
  end

  prompt_dir = trim_trailing_slash(prompt_dir)
  local prompt_file = prompt_dir .. "/" .. task .. ".prompt.md"

  vim.fn.mkdir(prompt_dir, "p")

  vim.cmd("cd " .. vim.fn.fnameescape(prompt_dir))
  vim.cmd("edit " .. vim.fn.fnameescape(prompt_file))
end

return M
