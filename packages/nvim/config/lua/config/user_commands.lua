
vim.api.nvim_create_user_command("HiPlugins", function()
  require("luasnip.loaders").edit_snippet_files({})
end, { desc = "Manage Plugins via Lazy" })
