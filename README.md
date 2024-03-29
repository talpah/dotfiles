# dotfiles

Oh-my-zsh with [powerlevel10k](https://github.com/romkatv/powerlevel10k.git) theme and [powerline](https://github.com/powerline/fonts) fonts

* Essential packages installed:
  * curl 
  * tree 
  * git 
  * zsh
  * oh-my-zsh
  * powerline fonts

* Optional goodies packages (see [Bonus Goodies](#bonus-goodies)):
  * docker
  * tilix
  * mc 
  * htop 
  * vim 
  * build-essential 

## Installing

### Via archive
#### Pre-requirements:
```bash
sudo apt-get install curl
```
#### Install
```bash
cd $HOME
curl -L https://github.com/talpah/dotfiles/archive/zsh.tar.gz | tar xz
mv dotfiles-zsh .dotfiles
.dotfiles/install.sh
```

### Via git (updatable)
#### Pre-requirements:
```bash
sudo apt-get install git
```
#### Install
```bash
cd $HOME
git clone -b zsh http://github.com/talpah/dotfiles.git .dotfiles
.dotfiles/install.sh
```

### Bonus goodies
```bash
$HOME/.dotfiles/bin/install_goodies.sh
```

## Uninstall
```bash
~/.dotfiles/uninstall.sh
```
