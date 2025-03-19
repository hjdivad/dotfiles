-- see https://github.com/dustinblackman/oatmeal.nvim#lazy-nvim
---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
  {
    "dustinblackman/oatmeal.nvim",
    cmd = { "Oatmeal" },
    keys = {},
    -- opts = {
    --   hotkey = "",
    --   backend = "ollama",
    --   model = "llama3:latest",
    -- },
    opts = {
      hotkey = "",
      -- Have to set OATMEAL_OPENAI_TOKEN
      backend = "openai",
      model = "gpt-4o",
    },
  },
}
