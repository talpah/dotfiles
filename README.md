# dotfiles

![](https://raw.githubusercontent.com/talpah/dotfiles/master/help/screen1.png)

* Prompt:
  * Shows current path, current git branch, and current virtualenv on the first line.
  * Auto switches virtualenv via `.venv` files inside directories when `cd`-ing.

* Essential packages installed:
  * curl 
  * tree 
  * git 
  * python2.7 
  * python-dev 
  * python-virtualenv

* Optional goodies packages (see [Bonus Goodies](#bonus-goodies)):
  * docker
  * dos2unix 
  * mc 
  * htop 
  * vim 
  * build-essential 
  * libmysqlclient-dev

## Installing

### Via archive
#### Pre-requirements:
```bash
sudo apt-get install curl
```
#### Install
```bash
cd $HOME
curl -L https://github.com/talpah/dotfiles/archive/master.tar.gz | tar xz
mv dotfiles-master .dotfiles
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
git clone http://github.com/talpah/dotfiles.git .dotfiles
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
