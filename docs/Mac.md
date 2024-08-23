# Mac OS

## Setup

**Minimal Keyboard Config for Sanity**

- max key repeat rate
- min delay until repeat
- customize modifier keys / caps lock -> control

**Install Preliminaries**

- install brave
- install [homebrew][]
- `brave://settings` -> set up sync
- install [rustup](https://www.rust-lang.org/tools/install)

```bash
brew install \
  kitty \
  neovim \
  tmux \
  fzf \
  z \
  rbenv \
  gh \
  volta \
  bat \
  ripgrep \
  fd \
  sheldon \
  sd \
  hyperfine \
  git-delta \
  tldr

volta install node
brew install cask font-hasklug-nerd-font

cd $HOME
ln -s Downloads tmp

mkdir docs
mkdir -p src/hjdivad
cd src/hjdivad
gh auth login
gh repo clone hjdivad/dotfiles
cd hjdivad/dotfiles
./install.zsh
```

- install [nonicons font](https://github.com/yamatsum/nonicons/blob/master/dist/nonicons.ttf)
- restart kitty

**Installation round 2**

```bash
rbenv install 3.3.3
rbenv global 3.3.3
gem install pws
```

- install from app store
  - divvy
- install outside of app store
  - [alfred](https://www.alfredapp.com/)
  - [telegram](https://desktop.telegram.org/)
  - [discord](https://discord.com/download)
  - [signal](https://signal.org/download/macos/)
  - [drovio](https://www.drovio.com/)
  - [flux](https://justgetflux.com/)
  - [krisp.ai](https://krisp.ai/)
  - [spotify](https://www.spotify.com/de-en/download/mac/)
  - [dash](https://kapeli.com/dash)
  - [obsidian](https://obsidian.md/download)
  - [iStat Menus](https://bjango.com/mac/istatmenus/)

```bash
# install fzf (^r, ^t)
$(brew --prefix)/opt/fzf/install

# Add $NEW_HOST to network
NEW_HOST="something"
sudo hostname $NEW_HOST
sudo scutil --set HostName $NEW_HOST
sudo scutil --set LocalHostName $NEW_HOST
```

- set up alfred
  - copy `$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/` from old machine to new
  - disable ⌘-space spotlight
  - enable ⌘-space alfred
- set up obsidian
  - open local vault (git clone)
  - connect it to remote vault
- set up divvy shortcuts
- set up system settings

[homebrew]: https://brew.sh/
