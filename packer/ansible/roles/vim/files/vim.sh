#!/bin/bash
# Disable auto-indent
sudo sed -i 's/  filetype plugin indent on/  filetype plugin indent off/g' /usr/share/vim/vim80/defaults.vim

# Disable visual mode when highlighting text with mouse
sudo sed -i 's/  set mouse=a/  set mouse-=a/g' /usr/share/vim/vim80/defaults.vim
