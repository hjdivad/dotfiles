local M = {}

---@param name string
function M.cache_path(name)
  return vim.fn.stdpath('cache') .. '/' .. 'hjdivad/' .. name
end

return M
