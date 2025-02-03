local tmux = require("hjdivad_util.tmux")

---@type LazySpec[]
return {
  -- see <~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/fzf.lua>
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
      { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
      {
        "<leader>,",
        false,
      },
      { "<leader>/", false },
      {
        "<leader>ff",
        function()
          local query = vim.g.fzf_default_query_files
          require("fzf-lua").files({ query = query })
        end,
        desc = "find files (root dir, default query)",
      },
      {
        "<leader>fl",
        function()
          require("fzf-lua").blines()
        end,
        desc = "find line in buffer",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags()
        end,
        desc = "find vim :help",
      },
      { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      {
        "<leader>fs",
        function()
          require("fzf-lua").spell_suggest()
        end,
        desc = "find spelling suggestion",
      },
      {
        "<leader>tsd",
        function()
          tmux.goto_tmux_session("📋 todos", "todos")
        end,
        desc = "tmux -> todos",
      },
      {
        "<leader>tsj",
        function()
          tmux.goto_tmux_session("📋 todos", "journal")
        end,
        desc = "tmux -> journal",
      },
      { "<leader>tst", "<Cmd>silent !tmux switch-client -l<cr>", desc = "tmux -> toggle" },
      {
        "<leader>tss",
        tmux.goto_fzf_tmux_session,
        desc = "tmux -> fzf session",
      },
    },
  },
}
