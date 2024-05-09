-- see https://github.com/dustinblackman/oatmeal.nvim#lazy-nvim
---@type LazySpec[]
return {
  {
    "dustinblackman/oatmeal.nvim",
    cmd = { "Oatmeal" },
    keys = {},
    opts = {
      hotkey = "",
      backend = "ollama",
      model = "llama3:latest",
    },
  },
}
