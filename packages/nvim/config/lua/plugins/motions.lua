local function leap_search()
  require("leap").leap({
    target_windows = vim.tbl_filter(function(win_id)
      local conf = vim.api.nvim_win_get_config(win_id)
      if conf.focusable == false then
        return false
      end
      if conf.relative ~= "" then
        return false
      end

      return true
    end, vim.api.nvim_list_wins()),
  })
end

return {
  -- easily jump to any location and enhanced f/t motions for Leap
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    dependencies = { { "ggandor/flit.nvim", opts = { labeled_modes = "nv" } } },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
    end,
    keys = {
      { "S", false },
      { "gs", false },
      { "s", false },
      {
        "<leader>gs",
        leap_search,
        desc = "Move cursor with leap labels",
      },
    },
  },

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
