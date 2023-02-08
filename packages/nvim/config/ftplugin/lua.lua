-- LDoc and LuaDoc start their docs with ---
-- However there's at least some convention for having all documentation begin
-- with ---, see e.g. the docs generated at
-- <https://github.com/sumneko/lua-language-server/blob/master/meta/template/string.lua>
vim.opt_local.comments:prepend(':---')

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

local expand = vim.fn['expand']
if expand('%:p'):find('/.vim/') or expand('%:t') == '.vimrc.lua' then
  vim.fn['UltiSnips#AddFiletypes']('nvim')
end
