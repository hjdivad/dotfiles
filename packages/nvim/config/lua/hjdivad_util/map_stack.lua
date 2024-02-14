local M = {}

local stacks = {}

M.ipush = function()
  -- TODO: destructures modes {n,v}, call normalized
  -- TODO: get rhs for <mode, lhs>
  -- if <rhs,opts && <rhs,opts> != stack[mode][lhs]
  --  stack[mode][lhs].push <rhs,opts>
  --  vim.keymap.set mode, lhs, rhs, options
end

M._debug = function()
  return {
    stacks=stacks
  }
end

return M
