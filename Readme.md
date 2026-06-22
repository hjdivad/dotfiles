## Daily Use

```sh
# Sets up go-task if needed and then sets up a clean machine or updates
./install
```

To force a re-install and clobber existing files

```sh
FORCE=true ./install
```

## Set Up

### MacOS

Personal notes on setting up MacOS.

**Minimal Keyboard Config for Sanity**

*system settings* -> *keyboard*
- max key repeat rate
- min delay until repeat

*system settings* -> *customize modifier keys*
- customize modifier keys / caps lock -> control

- install [1password](https://1password.com/downloads/mac) and log in
  - set up 1password with default browser so it can be the passkey source

**(Option 1) Install via bootstrap**

```sh
# bootstrap makes a couple empty directories, checks out this repo and runs install.
bash -c "$(curl --location https://raw.githubusercontent.com/hjdivad/dotfiles/refs/heads/master/bootstrap.sh)"
```

**(Option 2) Install manually**

```sh

# Set up some dirs
mkdir -p ~/src/vadnu
mkdir -p ~/src/github/hjdivad
(cd ~ && ln -s Downloads tmp)

# Check out this repo
cd ~/src/github/hjdivad
# When invoking this you may be prompted to install xcode command-line tools
git clone https://github.com/hjdivad/dotfiles.gita

cd ~/src/github/hjdivaddotfiles
# Then run install within the repo

# FIXME: This step has to be repeated a couple of times due to:
# 1. After installing homebrew, run in a new shell to get brew on PATH
# 2. brew will then fail due to trust issues (for e.g. rwjblue/tap).
# 3. cyclic dep between copy_dotfiles and cache-shell-startup
./install

# When prompted by gh, answer:
# 1. github.com
# 2. https
# 3. do not log in 


# (OPTIONAL) Install a local dotfiles
cd ~/src/github/hjdivad/dotfiles/
gh repo checkout {my-org-user}/{my-dotfiles}.git

# re-run to get local-dotfiles refinements
./install
```

- set up touchpad (system settings -> trackpad)
  - point & click
    - click -> light
    - tap to click -> on
    - look up & data detectors -> off
  - gestures
    - swipe pages -> 3 fingers
    - full-screen -> 4 fingers
    - mission control -> 4 fingers
    - App expose -> off

- install [berkeley mono font](https://berkeleygraphics.com/typefaces/berkeley-mono/)
- install [nonicons font](https://github.com/yamatsum/nonicons/blob/master/dist/nonicons.ttf)
- set up [wezterm terminfo](https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines)

- set up brave
  - 1password extension
  - react developer tools extension
  - vimium extension
  - brave://settings
  - brave://extensions/shortcuts
- set up [1password commit signing](https://www.1password.dev/ssh/git-commit-signing)
- set up obsidian
  - open local vault in `~/src/vadnu/${vault}`
  - connect it to remote vault
- set up alfred
  - enable ⌘-space alfred
  - disable ⌘-space spotlight
    - system settings -> keyboard shortcuts -> spotlight
  - set up [alfred-chromium-workflow](https://github.com/jopemachine/alfred-chromium-workflow)
    - set up hotkeys
      - `chb` -> `bb` (retrieve bookmarks)
      - `chh` -> `bh` (retrieve visit histories)
      - `cht` -> `b` (list all tabs)
  - set up [devtoys](https://alfred.app/workflows/cagechung/devtoys/)
- set up iStat Menus
- set up system settings

**(Optional) Installs**

- [cleanshot](https://cleanshot.com/)
- [telegram](https://desktop.telegram.org/)
- [spotify](https://www.spotify.com/de-en/download/mac/)
- [signal](https://signal.org/download/macos/)

**(Optional) Brave settings**

Open `brave://settings` in brave and set up sync.

**(Optional) Set host name**

```bash
NEW_HOST="something"
sudo hostname $NEW_HOST
sudo scutil --set HostName $NEW_HOST
sudo scutil --set LocalHostName $NEW_HOST
```
