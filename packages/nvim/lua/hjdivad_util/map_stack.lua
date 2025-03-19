---@class MapStack
local M = {}

local stack = {}

local function reset()
  stack = {}
end

local function tbl_empty_dict(t)
  for _, _ in pairs(t) do
    return false
  end

  return true
end

---@param lhs string
---@param mode string
local function push_restore_fn(lhs, mode)
  ---@type table
  ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
  local maparg = vim.fn.maparg(lhs, mode, false, true)
  if maparg["buffer"] == 1 then
    --FIXME: handle case where a buf-local mapping shadowed a global mapping we
    --should have restored here
    --
    --e.g.
    --    nmap lhs rhs_g
    --    nmap <buffer>  lhs rhs
    --    push
    --      nmap lhs rhs2
    --    pop
    --
    --probably requires manually re-implementing maparg and mapset, which is
    --also needed for proper buffer keymap support
    maparg = {}
  end

  local restore_fn
  if tbl_empty_dict(maparg) then
    restore_fn = function()
      vim.keymap.del(mode, lhs)
    end
  else
    restore_fn = function()
      vim.fn.mapset(mode, false, maparg)
    end
  end

  local frame = stack[#stack]
  table.insert(frame, restore_fn)
end

---@class KeymapProxy
local keymap = {}

---@param modes string|table
---@param cb fun(mode: string)
local function for_each_mode(modes, cb)
  if type(modes) == "table" then
    for _, mode in ipairs(modes) do
      cb(mode)
    end
  elseif type(modes) == "string" then
    cb(modes)
  else
    error("Invalid type(modes) '" .. type(modes) .. "'")
  end
end

---@param modes string|table
---@param lhs string
---@param rhs string|function
---@param opts? table
---see :help vim.keymap.set
keymap.set = function(modes, lhs, rhs, opts)
  for_each_mode(modes, function(mode)
    push_restore_fn(lhs, mode)
    vim.keymap.set(mode, lhs, rhs, opts)
  end)
end

---@param modes string|table
---@param lhs string
---@param opts? table
---see :help vim.keymap.del
keymap.del = function(modes, lhs, opts)
  for_each_mode(modes, function(mode)
    push_restore_fn(lhs, mode)
    vim.keymap.del(mode, lhs, opts)
  end)
end

keymap.buf = {}

---@param buffer integer
---@param modes string|table
---@param lhs string
---@param rhs string|function
---@param opts? table
keymap.buf.set = function(buffer, modes, lhs, rhs, opts)
  for_each_mode(modes, function(mode)
    -- push_restore_fn(...)
    -- vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
  end)
end

---@param buffer integer
---@param modes string|table
---@param lhs string
---@param opts? table
keymap.buf.del = function(buffer, modes, lhs, opts)
  for_each_mode(modes, function(mode)
    -- push_restore_fn(...)
    -- vim.api.nvim_buf_del_keymap(buffer, mode, lhs)
  end)
end

---Create a new keymap frame.  `cb` will be called with a stack-aware `keymap`
---that can be used the same as `vim.keymap.set` and `vim.keymap.del`.  Any
--changes made will be saved to the current stack frame and can be shadowed by
--future calls to `push`, and undone by calls to `pop`.
---
---@param cb fun(keymap: KeymapProxy)
M.push = function(cb)
  table.insert(stack, {})
  cb(keymap)
end

---Remove the most recent stack frame, restoring the state of the keymaps at
---the prior frame.
M.pop = function()
  -- run all the restore operations to undo the effects of the mappings set during the last push
  local frame = stack[#stack]
  for _, restore_fn in ipairs(frame) do
    restore_fn()
  end
  table.remove(stack)
end

M._debug = function()
  return {
    stack = stack,
    reset = reset,
  }
end

return M
