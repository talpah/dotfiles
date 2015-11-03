#!/bin/bash
sudo apt-get install -y \
curl \
tree \
git \
python2.7 \
python-pip \
python-dev \
python-virtualenv \
zsh

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cd ~/.oh-my-zsh/custom
git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k

sudo pip install virtualenvwrapper thefuck

mkdir -p ~/tmp/fonts
cd ~/tmp/fonts
git clone https://github.com/powerline/fonts.git .
./install.sh
