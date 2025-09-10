local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local function is_buffer_in_git_subdir()
  local buf_path = vim.fn.bufname("%")
  return (buf_path:match("^%.git/") ~= nil) or (buf_path:match("/%.git/") ~= nil)
end

-- Don't attempt to install missing plugins when editing a .git/ file, i.e.
-- when we're probably launched by git as part of a rebase or commit
local install_missing_plugins = not is_buffer_in_git_subdir()

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "catppuccin-mocha"
      }
    },
    { import = "plugins" },
    -- NOTE: local_nvim is symlinked in from local-dotfiles to allow for local
    -- system specific customizations
    -- see: https://github.com/malleatus/shared_binutils/blob/master/global/src/bin/setup-local-dotfiles.rs
    { import = "local_nvim.plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  -- TODO: configure tokyonight? https://github.com/folke/tokyonight.nvim#%EF%B8%8F-configuration
  -- TODO: configure catppuccin https://github.com/catppuccin/nvim?tab=readme-ov-file#configuration
  install = {
    missing = install_missing_plugins,
    colorscheme = { "catpuccin-mocha", "tokyonight", "habamax" },
  },
  checker = {
    -- disable automatic plugin updating.
    -- manually updating can be done via the lazyvim ui
    enabled = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

--TODO: I'd rather not create this here, but if I do it in config/* it'll eval
--after +cmds and I won't be able to do nvim +StartAgent
vim.api.nvim_create_user_command("StartAgent", function()
  -- TODO: take an arg (autocomplete agent names from agent lib)
  require('hjdivad.agent').StartAgent()
end, { desc = "Start a CLI Agent" })
