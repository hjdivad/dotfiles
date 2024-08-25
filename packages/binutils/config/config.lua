---@type Config
return {
	tmux = {
		sessions = {
			{
				name = "📋 todos",
				windows = {
					{
						name = "todos",
						path = "~/docs/vadnu/home",
						command = "nvim",
					},

					{
						name = "reference",
						path = "~/docs/vadnu/home/ref",
						command = "nvim",
					},

					{
						name = "journal",
						path = "~/docs/vadnu/home/journal",
						command = "nvim",
					},
				},
			},

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
		},
	},

  shell_caching = {
    source = "~/src/github/hjdivad/dotfiles/packages/zsh/",
    destination = "~/src/github/hjdivad/dotfiles/packages/zsh/dist",
  }
}
