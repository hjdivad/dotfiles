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

- max key repeat rate
- min delay until repeat
- customize modifier keys / caps lock -> control

**(Option 1) Install via bootstrap**

```sh
# bootstrap makes a couple empty directories, checks out this repo and runs install.
bash -c "$(curl --location https://raw.githubusercontent.com/hjdivad/dotfiles/refs/heads/master/bootstrap.sh)"
./install
```

**(Option 2) Install manually**

```sh

# Set up some dirs
mkdir -p ~/src/vadnu
mkdir -p ~/src/github/hjdivad
(cd ~ && ln -s Downloads tmp)

# Check out this repo
cd ~/src/github/hjdivad
git clone https://github.com/hjdivad/dotfiles.git

# Then run install within the repo
./install
```


- install brave

**(Optional) Brave settings**

Open `brave://settings` in brave and set up sync.

- set up [wezterm terminfo](https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines)
- install [berkeley mono font](https://berkeleygraphics.com/typefaces/berkeley-mono/)
- install [nonicons font](https://github.com/yamatsum/nonicons/blob/master/dist/nonicons.ttf)
- install from app store
  - divvy
- install outside of app store
  - [alfred](https://www.alfredapp.com/)
  - [telegram](https://desktop.telegram.org/)
  - [discord](https://discord.com/download)
  - [signal](https://signal.org/download/macos/)
  - [drovio](https://www.drovio.com/)
  - [flux](https://justgetflux.com/)
  - [spotify](https://www.spotify.com/de-en/download/mac/)
  - [dash](https://kapeli.com/dash)
  - [obsidian](https://obsidian.md/download)
  - [iStat Menus](https://bjango.com/mac/istatmenus/)

- set up alfred
  - copy `$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/` from old machine to new
  - disable ⌘-space spotlight
  - enable ⌘-space alfred
- set up obsidian
  - open local vault (git clone)
  - connect it to remote vault
- set up divvy shortcuts
- set up system settings

**(Optional) Set host name**

```bash
NEW_HOST="something"
sudo hostname $NEW_HOST
sudo scutil --set HostName $NEW_HOST
sudo scutil --set LocalHostName $NEW_HOST
```
