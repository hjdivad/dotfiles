---@type LazySpec[]
return {
  {
    "tyru/open-browser.vim",
    config = function()
      vim.g.netrw_nogx = true -- disable netrw's gx mapping
    end,
    keys = {
      {
        "gx",
        "<Plug>(openbrowser-open)",
        mode = "n",
        desc = "open (link under cursor) in browser",
        remap = false,
      },
    },
  },
}
