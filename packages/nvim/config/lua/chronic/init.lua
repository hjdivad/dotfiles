local M = {}

---Parses a natural language string as a date or time.
---Inspired by <https://github.com/mojombo/chronic>
---
function M.parse(str, options)
  local opts = vim.tbl_deep_extend('force', {}, options or {})
  local fmt = opts.format or 'default'

  -- TODO: actually implement ^_^
  return os.date('%e %b %Y (%A)')
end

return M
