---@class Zellij
local M = {}

local function in_zellij()
  local env_keys = vim.tbl_keys(vim.fn.environ())
  return vim.tbl_contains(env_keys, 'ZELLIJ')
end

---@param dir "left"|"right"|"up"|"down"
local function zellij_move_focus(dir)
  vim.system({ "zellij", "action", "move-focus", dir })
end

---@param dir "h"|"l"|"k"|"j"
---@return boolean
local function at_edge(dir)
  return vim.fn.winnr(dir) == vim.fn.winnr()
end

---@param dir "left"|"right"|"up"|"down"
---@param wincmd_dir "h"|"l"|"k"|"j"
local function winmove_or_zellij(dir, wincmd_dir)
  if at_edge(wincmd_dir) then
    zellij_move_focus(dir)
  else
    vim.cmd("wincmd " .. wincmd_dir)
  end
end

function M.winleft()
  winmove_or_zellij("left", "h")
end

function M.winright()
  winmove_or_zellij("right", "l")
end

function M.winup()
  winmove_or_zellij("up", "k")
end

function M.windown()
  winmove_or_zellij("down", "j")
end

function M.keymap_winleft()
  if in_zellij() then
    return M.winleft
  end

  return '<Cmd>wincmd h<Cr>'
end

function M.keymap_winright()
  if in_zellij() then
    return M.winright
  end

  return '<Cmd>wincmd l<Cr>'
end

function M.keymap_winup()
  if in_zellij() then
    return M.winup
  end

  return '<Cmd>wincmd k<Cr>'
end

function M.keymap_windown()
  if in_zellij() then
    return M.windown
  end

  return '<Cmd>wincmd j<Cr>'
end

return M
