#!/bin/bash

set -e

# set up directory structure
mkdir -p ~/src/vadnu
mkdir -p ~/src/github/hjdivad
(cd ~ && ln -s Downloads tmp)

cd ~/src/github/hjdivad
git clone https://github.com/hjdivad/dotfiles.git
./install
