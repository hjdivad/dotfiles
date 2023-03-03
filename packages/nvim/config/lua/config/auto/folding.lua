local M = {}

local function augroup(name)
  return vim.api.nvim_create_augroup("hjd_fold_" .. name, { clear = true })
end

function M.setup( )
  --code
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("treesitter_folding"),
    -- enable treesitter folding
    -- to start folding in a file, zx
    pattern = { "markdown", "typescript", "lua" },
    callback = function()
      -- see https://github.com/nvim-treesitter/nvim-treesitter#folding
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.wo.foldlevel = 1
      vim.wo.foldenable = true
    end,
  })
end


return M
