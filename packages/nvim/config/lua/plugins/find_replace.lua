return {
  -- search/replace in multiple files
  {
    "windwp/nvim-spectre",
    -- stylua: ignore
    keys = {
      {'<leader>sr', false},
      { "<leader>fr", function() require("spectre").open() end, desc = "Find [and replace] in files (Spectre)" },
    },
  },
}
