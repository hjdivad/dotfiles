return {

  {
    -- https://github.com/kylechui/nvim-surround#package-installation
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "S", mode = "v" },
    },
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          -- https://github.com/kylechui/nvim-surround/blob/056f69ed494198ff6ea0070cfc66997cfe0a6c8b/lua/nvim-surround/config.lua#L8-L18
          insert = false,
          insert_line = false,
          visual_line = false,
          visual = "S",
        },
      })
    end,
  },
}
