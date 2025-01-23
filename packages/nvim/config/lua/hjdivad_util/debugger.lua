local M = {}

function M.debug_nvim()
  local osv = require("osv")
  if osv.is_running() then
    osv.stop()
    vim.print("server stopped")
  else
    osv.launch({ port = 8086 })
  end
end

return M
