# SSH agent - quiet mode
zstyle :omz:plugins:ssh-agent quiet yes

# Enable Powerlevel10k instant prompt (keep at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Oh My Zsh Configuration
# ============================================================================

export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Completion settings
COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX=true

# Plugins (docker includes compose v2 support)
plugins=(
    git
    common-aliases
    docker
    python
    pip
    sudo
    command-not-found
    ssh-agent
    aws
    zsh-navigation-tools
    ruff
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# Modern ZSH Settings
# ============================================================================

# History improvements
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_VERIFY               # Show command before running from history
setopt SHARE_HISTORY             # Share history between sessions

# Directory navigation
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack

# Globbing
setopt EXTENDED_GLOB             # Extended globbing syntax

# Completion improvements
setopt COMPLETE_IN_WORD
setopt AUTO_MENU
setopt AUTO_LIST

# ============================================================================
# PATH Configuration
# ============================================================================

# Helper function to add to PATH only if directory exists and not already in PATH
add_to_path() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Add custom paths
add_to_path "${HOME}/bin"
add_to_path "${HOME}/.local/bin"

# ============================================================================
# Environment
# ============================================================================

export LANG=en_US.UTF-8
export EDITOR=vim

# Load local environment if exists
[[ -e "$HOME/.zshenv" ]] && source "$HOME/.zshenv"

# ============================================================================
# Completions
# ============================================================================

# Custom completions (ruff, etc.)
fpath=(~/.dotfiles/zfunc $fpath)

# Cache completions for faster startup (rebuild daily)
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# ============================================================================
# Key Bindings
# ============================================================================

# zsh-navigation-tools
zle -N znt-cd-widget
bindkey "^B" znt-cd-widget
zle -N znt-kill-widget
bindkey "^Y" znt-kill-widget

# ============================================================================
# Tool Integrations
# ============================================================================

# Powerlevel10k prompt config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Homebrew (Linuxbrew)
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# LM Studio CLI
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

# SOPS encryption
export SOPS_AGE_KEY_FILE="$HOME/.sops/age.agekey"

# ============================================================================
# Aliases
# ============================================================================

# GitLab merge request
alias mr='glab mr create -t "$(git rev-parse --abbrev-ref HEAD)" -d "Resolve $(git rev-parse --abbrev-ref HEAD)"'

# batcat (Ubuntu package name)
command -v batcat &> /dev/null && alias bat='batcat'
command -v batcat &> /dev/null && alias cat='batcat'
