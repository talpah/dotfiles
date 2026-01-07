# dotfiles

Modern development environment setup with Oh-my-zsh, [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme, and [Powerline](https://github.com/powerline/fonts) fonts.

## Quick Start

```bash
# Via git (recommended)
git clone -b zsh https://github.com/talpah/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install

# Install optional goodies
make goodies
```

## What's Included

### Essential packages (`make install`):
- curl, tree, git, zsh
- oh-my-zsh with powerlevel10k theme
- Powerline fonts

### Configuration files:
- `.zshrc` - Modern zsh config with history, completions, and PATH management
- `.gitconfig` - Git aliases and modern settings (zdiff3, histogram diff, etc.)
- `config/ghostty/` - Ghostty terminal emulator config

### Optional goodies (`make goodies`):
- **System utilities**: tilix, mc, btop, vim, build-essential
- **batcat** - Syntax-highlighted cat replacement
- **Docker** - Container runtime with compose plugin
- **gh** - GitHub CLI
- **glab** - GitLab CLI

## Installation

### Via archive
```bash
curl -L https://github.com/talpah/dotfiles/archive/zsh.tar.gz | tar xz
mv dotfiles-zsh ~/.dotfiles
~/.dotfiles/install.sh
```

### Via git (recommended)
```bash
git clone -b zsh https://github.com/talpah/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

## Usage

```bash
make help       # Show available commands
make install    # Install dotfiles
make goodies    # Install optional packages
make update     # Update oh-my-zsh and powerlevel10k
make test       # Run shellcheck tests
make uninstall  # Uninstall dotfiles
make clean      # Clean backup directory
```

## Uninstall

```bash
make uninstall
# or
~/.dotfiles/uninstall.sh
```

## Features

### Modern ZSH Settings
- Extended history with timestamps and deduplication
- Auto-cd (type directory name to cd)
- Directory stack with auto-pushd
- Extended globbing
- Completion caching for faster startup

### Zsh Plugins
- git, docker (includes compose v2)
- python, pip, ruff
- common-aliases, sudo, command-not-found
- ssh-agent, aws, zsh-navigation-tools

### Git Configuration
- Modern defaults: `init.defaultBranch = main`, `push.default = simple`
- Better diffs: histogram algorithm, colorMoved
- Safety: `pull.ff = only`, fsck on transfer
- Auto-prune on fetch
- Useful aliases: `sw` (switch), `s` (status -sb), `undo`, `amend`, `gone`

### Custom Aliases
- `mr` - Create GitLab merge request from current branch
- `bat` - Alias for batcat (Ubuntu naming)

### Key Bindings
- `Ctrl+B` - zsh navigation tools (cd widget)
- `Ctrl+Y` - zsh navigation tools (kill widget)

## Requirements

- Ubuntu or Debian-based Linux
- sudo access for package installation

## License

MIT
