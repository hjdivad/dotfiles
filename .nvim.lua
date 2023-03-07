vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "*_spec.lua",
	group = vim.api.nvim_create_augroup("hjdivad_exrc", { clear = true }),
	callback = function()
    -- TODO: make buflocal & unset when leaving
		vim.keymap.set("n", "<leader>rt", function()
			require("plenary.test_harness").test_directory(
				vim.fn.expand("%:p"),
				{ minimal_init = "tests//init.lua", sequential=true }
			)
		end, { desc = "Run the current file's tests in Plenary", buffer = true })
	end,
})
