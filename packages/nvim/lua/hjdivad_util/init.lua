local map_stack = require("hjdivad_util/map_stack")

local M = {}

M.map_stack = map_stack

--- Concatenates multiple array-like tables into one.
--- This function accepts a variable number of table
--- arguments and concatenates their elements into a single
--- table. The tables should have integer keys starting
--- from 1. It does not handle non-integer keys and will
--- not work correctly with -dictionary-like tables.
---
---@vararg table The tables to concatenate. Each argument should be an array-like table.
---@return table A new table containing all elements from the input tables.
---
function M.concat(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for i = 1, #tbl do
      result[#result + 1] = tbl[i]
    end
  end
  return result
end

function M.args_list(str)
  local result = {}
  local word = ""
  local quote = nil

  for i = 1, #str do
    local char = str:sub(i, i)

    if quote == nil then
      if char == " " or char == "\t" then
        if #word > 0 then
          table.insert(result, word)
          word = ""
        end
      elseif char == "'" then
        quote = "'"
      elseif char == '"' then
        quote = '"'
      else
        word = word .. char
      end
    else
      if char == quote then
        quote = nil
        if #word > 0 then
          table.insert(result, word)
          word = ""
        end
      else
        word = word .. char
      end
    end
  end

  if #word > 0 then
    table.insert(result, word)
    word = ""
  end

  return result
end

return M
