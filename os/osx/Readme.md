# OSX

## Installation

- install [homebrew][]
- install [alacritty][] (@ master)
- install rbenv
- install volta
- `gem install pws`
- `brew install neovim`
- `brew install tmux`
- `brew install z`
- log in to apple store
- install from app store or wherever
  - divvy
  - dash
  - spotify
  - alfred
  - discord
  - telegram
  - flux
  - signal
  - use-together
- install xcode
- install vscode (ref &c.)

Probably don't install but vaguely recall
  - skitch

## Configs

- keyboard setup
  - caps lock to ctrl
  - swap ⌘ and option

- system prefs
  - spotlight add dirs to not index
    - `.volta`
    - `.rbenv`
    - `docs`
    - `src`
    - `tmp`

[disable animations][]:
```
# opening and closing windows and popovers
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# showing and hiding sheets, resizing preference windows, zooming windows
# float 0 doesn't work
defaults write -g NSWindowResizeTime -float 0.001

# opening and closing Quick Look windows
defaults write -g QLPanelAnimationDuration -float 0

# showing a toolbar or menu bar in full screen
defaults write -g NSToolbarFullScreenAnimationDuration -float 0

# showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0

# showing and hiding Mission Control, command+numbers
defaults write com.apple.dock expose-animation-duration -float 0

# showing and hiding Launchpad
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0

# changing pages in Launchpad
defaults write com.apple.dock springboard-page-duration -float 0

# at least AnimateInfoPanes
defaults write com.apple.finder DisableAllAnimations -bool true
```

[alacritty]: https://github.com/jwilm/alacritty/blob/master/INSTALL.md
[homebrew]: https://brew.sh/
[disable animations]: https://apple.stackexchange.com/questions/14001/how-to-turn-off-all-animations-on-os-x
