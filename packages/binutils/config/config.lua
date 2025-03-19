-- $HOME/.config/.luarc.json
-- {
--   "$schema": "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
--   "workspace": {
--     "library": [
--        "~/src/github/malleatus/shared_binutils/config",
--     ]
--   }
-- }

---@type Config
return {
  crate_locations = {
    "~/src/github/hjdivad/dotfiles/packages/binutils/",
    "~/src/github/hjdivad/dotfiles/local-packages/binutils/",
    "~/src/github/malleatus/shared_binutils/"
  },

	tmux = {
		sessions = {
			{
				name = "🟡 dotfiles",
				windows = {
					{
						name = "dotfiles",
						path = "~/src/github/hjdivad/dotfiles",
						command = "nvim",
					},

					{
						name = "binutils",
						path = "~/src/github/hjdivad/dotfiles/packages/binutils",
						command = "nvim",
					},

					{
						name = "shared-binutils",
						path = "~/src/github/malleatus/shared_binutils/",
						command = "nvim",
					},

					{
						name = "local-packages",
						path = "~/src/nas/hjdivad/local-dotfiles/",
						command = "nvim",
					},

					{
						name = "rwjblue/dotfiles",
						path = "~/src/github/rwjblue/dotfiles",
						command = "nvim",
					},

					{
						name = "rwjblue/dotvim",
						path = "~/src/github/rwjblue/dotvim",
						command = "nvim",
					},
				},
			},

			{
				name = "💪 ud_macros",
				windows = {
					{
						name = "ud_macros",
						path = "~/src/github/hjdivad/ud_macros",
						command = "nvim",
					},

					{
						name = "sandbox-kotlin",
						path = "~/src/nas/hjdivad/sandbox-kotlin",
						command = "nvim",
					},

					{
						name = "sandbox-android",
						path = "~/src/nas/hjdivad/sandbox-android",
						command = "nvim",
					},

					{
						name = "sandbox-android2",
						path = "~/src/nas/hjdivad/sandbox-android",
						command = "nvim",
					},
				},
			},

			{
				name = "🦾 montoya",
				windows = {
					{
						name = "montoya",
						path = "~/src/github/malleatus/montoya.nvim",
						command = "nvim",
					},

					{
						name = "montoya2",
						path = "~/src/github/malleatus/montoya.nvim",
						command = "nvim",
					},
				},
			},

			{
				name = "🧩 sandbox",
				windows = {
					{
						name = "sandbox-go",
						path = "~/src/nas/hjdivad/sandbox-go/",
						command = "nvim",
					},
				},
			},

			{
				name = "📋 todos",
				windows = {
					{
						name = "todos",
						path = "~/docs/vadnu/home",
						command = "nvim",
					},

					{
						name = "journal",
						path = "~/docs/vadnu/home",
						command = "nvim +EditToday",
					},
				},
			},
		},
	},

	shell_caching = {
		source = "~/src/github/hjdivad/dotfiles/packages/zsh/",
		destination = "~/src/github/hjdivad/dotfiles/packages/zsh/dist",
	},
}
