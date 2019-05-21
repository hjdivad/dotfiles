# OSX

## Installation

- install [homebrew][]
- install [alacritty][] (@ master)
- install bluejeans beta if needed
- log in to apple store
- install from app store or wherever
  - divvy
  - dash
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

```
# install brew packages
brew install adns android-ndk android-sdk ant aom autoconf automake azure-cli cairo ccat chromedriver cmake coreutils cscope ffmpeg findutils fish flac fontconfig freetype frei0r fribidi fzf gcc gd gdbm gettext giflib glib gmp gnupg gnutls gradle graphite2 graphviz grep harfbuzz htop httpie hub icu4c isl jemalloc jpeg jq lame leptonica libass libassuan libbluray libevent libffi libgcrypt libgpg-error libksba libmpc libogg libpng libsamplerate libsndfile libsoxr libtasn1 libtermkey libtiff libtool libunistring libusb libuv libvorbis libvpx libvterm libyaml little-cms2 lsusb luajit macvim maven mpfr msgpack neovim nettle ninja node npth nspr nss oniguruma opencore-amr openjpeg openssl opus p11-kit pcre pcre2 phantomjs pinentry pixman pkg-config pstree python python3 r rbenv readline reattach-to-user-namespace rlwrap rtmpdump rubberband ruby-build rustup-init sdl2 snappy speex sqlite tesseract the_silver_searcher theora tmux typescript unbound unibilium watchman webp x264 x265 xvid xz yarn z
```

## Configs

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
