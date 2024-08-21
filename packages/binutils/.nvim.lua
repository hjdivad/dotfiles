local function startup()
  vim.cmd([[
    tabnew
    terminal
    tabnext 1
    stopinsert
  ]])
end

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = "*",
	group = vim.api.nvim_create_augroup("hjdivad_enter", { clear = true }),
	callback = function()
    vim.defer_fn(startup, 10)
	end,
})
