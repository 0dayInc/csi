#!/bin/bash
default_vimrc='/usr/share/vim/vim81/defaults.vim'
global_vimrc='/etc/vim/vimrc'

sudo apt install -y vim

sudo cp $global_vimrc $global_vimrc.dpkg-ORIG
sudo /bin/bash --login -c "cat ${default_vimrc} > ${global_vimrc}"
# Disable auto-indent
sudo /bin/bash --login -c "sed -i 's/  filetype plugin indent on/  filetype plugin indent off/g' ${global_vimrc}"

# Disable visual mode when highlighting text with mouse
sudo /bin/bash --login -c "sed -i 's/  set mouse=a/  set mouse-=a/g' ${global_vimrc}"

# Ensure Global vimrc overrides default vimrc
sudo /bin/bash --login -c "echo 'let skip_defaults_vim=1' >> ${global_vimrc}"
