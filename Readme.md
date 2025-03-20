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

**(Optional) Brave settings**

Open `brave://settings` in brave and set up sync.

- set up [wezterm terminfo](https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines)
- install [berkeley mono font](https://berkeleygraphics.com/typefaces/berkeley-mono/)
- install [nonicons font](https://github.com/yamatsum/nonicons/blob/master/dist/nonicons.ttf)
- install outside of app store
  - [iStat Menus](https://bjango.com/mac/istatmenus/)
- optional installs
  - [telegram](https://desktop.telegram.org/)
  - [spotify](https://www.spotify.com/de-en/download/mac/)
  - [signal](https://signal.org/download/macos/)

- set up alfred
  - disable ⌘-space spotlight
  - enable ⌘-space alfred
  - set up [alfred-chromium-workflow](https://github.com/jopemachine/alfred-chromium-workflow)
  - set up [chatgpt workflow](https://alfred.app/workflows/alfredapp/openai/)
  - set up [menubar search](https://alfred.app/workflows/benziahamed/menu-bar-search/)
  - set up [audio switcher](https://alfred.app/workflows/tobiasmende/audio-switcher/)
  - set up [gitfred](https://alfred.app/workflows/chrisgrieser/gitfred/)
  - set up [image placeholders](https://alfred.app/workflows/alfredapp/placeholder-images/)
  - set up [roman numeral](https://alfred.app/workflows/zeitlings/roman-numeral/)
  - set up [ocr](https://alfred.app/workflows/alanhe/ocr/)
  - set up [color picker](https://alfred.app/workflows/zeitlings/color-picker/)
  - set up [gif from video](https://alfred.app/workflows/zeitlings/gif-from-video/)
  - set up [gif search](https://alfred.app/workflows/rknightuk/gif-search/)
  - set up [devtoys](https://alfred.app/workflows/cagechung/devtoys/)
  - set up [lorem ipsum](https://alfred.app/workflows/alexchantastic/lorem-ipsum/)
  - set up [qr codes](https://alfred.app/workflows/torreybetts/qr-code/)
- set up obsidian
  - open local vault in `~/src/vadnu/${vault}`
  - connect it to remote vault
- set up system settings
- set up iStat Menus

**(Optional) Set host name**

```bash
NEW_HOST="something"
sudo hostname $NEW_HOST
sudo scutil --set HostName $NEW_HOST
sudo scutil --set LocalHostName $NEW_HOST
```
