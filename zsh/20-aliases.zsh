# ============================================================================
# Aliases
# ============================================================================
# Core commands are replaced by modern equivalents where installed. Every
# replacement is guarded, so a machine without the tool keeps the original.
# Escape any alias with a leading backslash: `\ls`, `\grep`, `\rm`.

# ---------------------------------------------------------------------------
# Listing - eza
# ---------------------------------------------------------------------------
if has eza; then
    alias ls='eza --group-directories-first --icons=auto'
    alias l='eza -lah --group-directories-first --icons=auto --git'
    alias ll='eza -lh  --group-directories-first --icons=auto --git'
    alias la='eza -lah --group-directories-first --icons=auto --git'
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
    alias ltt='eza --tree --level=4 --group-directories-first --icons=auto'
    alias lm='eza -lah --group-directories-first --icons=auto --sort=modified'
    alias tree='eza --tree --icons=auto'
else
    alias l='ls -lah'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# ---------------------------------------------------------------------------
# Viewing - bat (packaged as batcat on Debian/Ubuntu)
# ---------------------------------------------------------------------------
if has bat; then
    alias cat='bat --paging=never'
    alias catp='bat --plain --paging=never'
elif has batcat; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
    alias catp='batcat --plain --paging=never'
fi

# ---------------------------------------------------------------------------
# Search - ripgrep and fd
# ---------------------------------------------------------------------------
has rg && alias grep='rg'
if has fd; then
    alias find='fd'
elif has fdfind; then
    alias fd='fdfind'
    alias find='fdfind'
fi

# ---------------------------------------------------------------------------
# Deletion - trash-cli. `\rm` still reaches the real thing.
# ---------------------------------------------------------------------------
if has trash-put; then
    alias rm='trash-put'
    alias rme='trash-empty'
    alias rml='trash-list'
    alias rmr='trash-restore'
fi

# ---------------------------------------------------------------------------
# Disk and process inspection
# ---------------------------------------------------------------------------
has dust && alias du='dust'
has duf && alias df='duf'
has procs && alias ps='procs'
has btop && alias top='btop'

# common-aliases (oh-my-zsh) defines `duf` as `du -sh *`; drop it so the real
# duf binary wins, and keep the original behaviour under a different name.
if has duf; then
    unalias duf 2>/dev/null
    alias dus='du -sh *'
fi

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
alias mr='glab mr create -t "$(git rev-parse --abbrev-ref HEAD)" -d "Resolve $(git rev-parse --abbrev-ref HEAD)"'
has lazygit && alias lg='lazygit'
alias gwl='git worktree list'
alias gwr='git worktree remove'

# ---------------------------------------------------------------------------
# Docker and Kubernetes
# ---------------------------------------------------------------------------
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=100'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
has lazydocker && alias ld='lazydocker'

# ---------------------------------------------------------------------------
# Python - uv only, per project convention
# ---------------------------------------------------------------------------
if has uv; then
    alias uvr='uv run'
    alias uvs='uv sync'
    alias uvi='uv pip install'
    alias uva='uv add'
    alias uvx='uv tool run'
    alias venv='uv venv && source .venv/bin/activate'
fi
alias ruffc='ruff check --fix'
alias rufff='ruff format'

# ---------------------------------------------------------------------------
# Misc
# ---------------------------------------------------------------------------
alias fix-audio='sudo modprobe -r snd_hda_scodec_tas2781_i2c && sleep 1 && sudo modprobe snd_hda_scodec_tas2781_i2c'
alias zreload='exec zsh'
alias dotfiles='cd "${DOTFILES}"'
alias path='echo ${PATH} | tr ":" "\n"'
alias ports='ss -tulpn'
