## Requirements

- bash
- curl
- gnu grep, either as `grep` or `ggrep`
- homebrew
- [nonicons font](https://github.com/yamatsum/nonicons/blob/master/dist/nonicons.ttf)

```bash
```

## Installation

```bash

# install volta
curl https://get.volta.sh | bash

brew install font-hasklug-nerd-font

# neovim
brew install neovim

# better git diff + pager
brew install git-delta

brew install fzf
# setup ~/.fzf.bash
/usr/local/opt/fzf/install

# starship for bash prompt
brew install starship

# install language servers
brew install lua-language-server
volta install typescript-language-server
volta install vim-language-server
volta install diagnostic-languageserver
volta install yaml-language-server

# set up dotfiles
./install.bash

# install local bin utils
cd packages/binutils && cargo install --path .
```

## Usage

See [Debugging.md](./Debugging.md)

### Project-Local Snippets

```lua
-- .nvim.lua

-- local-snippet<complete>
```


