return {
  -- easily jump to any location and enhanced f/t motions for Leap
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    dependencies = { { "ggandor/flit.nvim", opts = { labeled_modes = "nv" } } },
    keys = {
      {
        "<leader>gs",
        function()
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
        end,
        desc = "Move cursor with leap labels",
      },
    },
  },
}
