--FIXME: Enabling this extra causes a lot of problems because it sets
--vim.opt.syntax = true
--
--You really don't want this for all kinds of languages (e.g. markdown, java)
--Realistically the thing to do is to write a treesitter grammar for d2.

---@type LazySpec
-- return {
--   --TODO: I'd rather use a TreeSitter grammar
--   --have to :syntax on for .d2 files
--   "terrastruct/d2-vim",
--   lazy = false
-- }

---@type LazySpec
return {}
