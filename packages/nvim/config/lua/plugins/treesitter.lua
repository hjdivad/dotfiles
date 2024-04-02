---@type LazySpec
return {
  -- see https://www.lazyvim.org/plugins/treesitter
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    enabled = true,
    opts = { mode = "cursor", max_lines = 3 },
    keys = {
      {
        "<leader>ut",
        false,
      },
    },
  },
}
