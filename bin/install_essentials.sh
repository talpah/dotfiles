#!/bin/sh
sudo apt-get install -y curl tree git zsh fonts-powerline

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd ~/.oh-my-zsh/custom
git clone https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k

