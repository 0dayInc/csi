#!/bin/bash
sudo apt install -y vim

# Disable auto-indent
sudo sed -i 's/  filetype plugin indent on/  filetype plugin indent off/g' /usr/share/vim/vim81/defaults.vim

# Disable visual mode when highlighting text with mouse
sudo sed -i 's/  set mouse=a/  set mouse-=a/g' /usr/share/vim/vim81/defaults.vim
