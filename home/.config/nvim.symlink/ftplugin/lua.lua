-- LDoc and LuaDoc start their docs with ---
-- However there's at least some convention for having all documentation begin
-- with ---, see e.g. the docs generated at
-- <https://github.com/sumneko/lua-language-server/blob/master/meta/template/string.lua>
vim.opt_local.comments:prepend(':---')
