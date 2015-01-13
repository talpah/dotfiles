# dotfiles

* Prompt:
  * Color
  * Current git branch
  * Current virtualenv
  * Auto change virtualenv via .venv files
* Essentials:
  * git
  * virtualenv
  * mc
  * htop
  * vim
  * build-essential
  * [docker](http://docker.io)

## Install
#### Via archive
```bash
cd $HOME
curl -L https://github.com/talpah/dotfiles/archive/master.tar.gz | tar xz
mv dotfiles-master .dotfiles
.dotfiles/install.sh
```

#### Via git (updatable)
```bash
cd $HOME
git clone git@github.com:talpah/dotfiles.git .dotfiles
.dotfiles/install.sh
```
## Uninstall
```bash
~/.dotfiles/uninstall.sh
```
