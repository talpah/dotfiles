# ============================================================================
# .zshrc - thin loader. Real configuration lives in ${DOTFILES}/zsh/*.zsh
# ============================================================================
# Machine-specific settings belong in ~/.zshrc.local (sourced last, untracked).

# SSH agent - quiet mode (must precede oh-my-zsh)
zstyle :omz:plugins:ssh-agent quiet yes

# Powerlevel10k instant prompt (keep at top, before any output)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Resolve the dotfiles repo by following this file's own symlink
DOTFILES="${${(%):-%N}:A:h}"
export DOTFILES

# ============================================================================
# Oh My Zsh
# ============================================================================

export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true       # faster paste in large buffers

# Homebrew must be initialised here, not in zsh/00-path.zsh. `brew shellenv`
# prepends its completions to fpath, and oh-my-zsh runs compinit while it is
# being sourced below - anything joining fpath after that is invisible to the
# completion system (atuin, eza, delta et al ship completions this way).
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "${HOME}/.linuxbrew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
fi

# Custom completions must join fpath before oh-my-zsh runs compinit
fpath=("${DOTFILES}/zfunc" $fpath)

# zsh-syntax-highlighting must stay last in this list
plugins=(
    tmux
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
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ============================================================================
# Shell options
# ============================================================================

# History
setopt EXTENDED_HISTORY          # write timestamps
setopt HIST_EXPIRE_DUPS_FIRST    # expire duplicates first
setopt HIST_IGNORE_DUPS          # don't record duplicates
setopt HIST_IGNORE_SPACE         # don't record commands starting with space
setopt HIST_REDUCE_BLANKS        # strip superfluous whitespace
setopt HIST_VERIFY               # confirm before running from history
setopt SHARE_HISTORY             # share history between sessions
HISTSIZE=100000
SAVEHIST=100000

# Directory navigation
setopt AUTO_CD                   # cd by typing a directory name
setopt AUTO_PUSHD                # push directories onto the stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Globbing and completion
setopt EXTENDED_GLOB
setopt COMPLETE_IN_WORD
setopt AUTO_MENU
setopt AUTO_LIST
setopt INTERACTIVE_COMMENTS      # allow # comments at the prompt

# ============================================================================
# Modules
# ============================================================================

for _zsh_module in "${DOTFILES}"/zsh/*.zsh(N); do
    source "${_zsh_module}"
done
unset _zsh_module

# ============================================================================
# Local overrides
# ============================================================================

# Powerlevel10k prompt config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Machine-specific config and anything installers append. Keep this last.
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"
