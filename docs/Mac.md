# OSX

## Installation

- install [homebrew][]
- install [inconsolata for powerline][]
- install [alacritty][] (>= 0.4.2-rc3)
- install rustup
- install volta
- `brew install bash`
- `brew install neovim`
- `brew install tmux`
- `brew install z`
- `brew install rbenv`
- `gem install pws`
- log in to apple store
- install from app store or wherever
  - divvy
  - spotify
  - alfred
  - discord
  - telegram
  - flux
  - signal
  - use-together
  - keycastr
  - soundsource
  - krisp.ai
- install explicitly from outside apple store
  - dash

## home
```sh
cd $HOME
ln -s tmp Downloads
mkdir src
```

## etc

```sh
# hostname $NEW_MACHINE_HOSTNAME

# cat '/usr/local/bin/bash' >> /etc/shells
# chsh -s /usr/local/bin/bash
```

## Configs

- trackpad
  - tap to click
  - disable "Look up & data detectors"
  - Swipe between pages: "three fingers"
  - disable "Swipe between full-screen apps"
  - mission control: "Up with four fingers"
  - disable "Launchpad"
  - disable "Show Desktop"

- keyboard setup
  - caps lock to ctrl
  - key repeat fast
  - repeat delay short
  - remove siri from touchbar
  - text
    - disable correct spelling automatically
    - disable capitalize words automatically
    - disable add period with double-space
    - disable touch bar typing suggestions
  - shortcuts
    - launchpad & dock disable all
    - display disable all
    - keyboard disable all except move focus to next window and focus status menus (⌘^-m)
    - services disable all
    - spotlight disable all (after installing alfred)
    - app shortcuts disable all
    - accessibility disable all

- keyboard setup extra: sculpt
  - swap ⌘ and option

- sharing
  - set computer name

- dock
  - position right
  - minimize using scale
  - ✅ automatically show & hide the dock
  - ❌ animate opening applications

- screensaver
  - hot corner bottom right start screensaver
  - start after 30 minutes
  - word of the day
  - show with clock

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

# smooth scrolling
defaults write -g NSScrollAnimationEnabled -bool false

# showing and hiding sheets, resizing preference windows, zooming windows
# float 0 doesn't work
defaults write -g NSWindowResizeTime -float 0.001

# opening and closing Quick Look windows
defaults write -g QLPanelAnimationDuration -float 0

# rubberband scrolling (doesn't affect web views)
defaults write -g NSScrollViewRubberbanding -bool false

# resizing windows before and after showing the version browser
# also disabled by NSWindowResizeTime -float 0.001
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false

# showing a toolbar or menu bar in full screen
defaults write -g NSToolbarFullScreenAnimationDuration -float 0

# scrolling column views
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

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

# sending messages and opening windows for replies
defaults write com.apple.Mail DisableSendAnimations -bool true
defaults write com.apple.Mail DisableReplyAnimations -bool true
```

disable dock bounce
```
defaults write com.apple.dock no-bouncing -bool TRUE
killall Dock
```

[alacritty]: https://github.com/jwilm/alacritty/blob/master/INSTALL.md
[inconsolata for powerline]: https://github.com/powerline/fonts/tree/master/Inconsolata
[homebrew]: https://brew.sh/
[disable animations]: https://apple.stackexchange.com/questions/14001/how-to-turn-off-all-animations-on-os-x
