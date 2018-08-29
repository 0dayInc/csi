#!/bin/bash
default_vimrc='/usr/share/vim/vim81/defaults.vim'
global_vimrc='/etc/vim/vimrc'

sudo apt install -y vim

sudo cp $global_vimrc $global_vimrc.BAK
sudo cat $default_vimrc > $global_vimrc
# Disable auto-indent
sudo sed -i 's/  filetype plugin indent on/  filetype plugin indent off/g' $global_vimrc

# Disable visual mode when highlighting text with mouse
sudo sed -i 's/  set mouse=a/  set mouse-=a/g' $global_vimrc

# Ensure Global vimrc overrides default vimrc
sudo echo 'let skip_defaults_vim=1' >> $global_vimrc
