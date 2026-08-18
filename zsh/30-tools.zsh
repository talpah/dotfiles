# ============================================================================
# Tool integrations
# ============================================================================
# Everything here is opt-in on presence: if the binary is missing the block is
# skipped silently, so a fresh machine still gets a working shell.

# ---------------------------------------------------------------------------
# fzf - fuzzy finder. Ctrl+T files, Ctrl+R history, Alt+C cd
# ---------------------------------------------------------------------------
if has fzf; then
    # fzf 0.48+ ships its own shell integration; older versions need the files
    if fzf --zsh &> /dev/null; then
        eval "$(fzf --zsh)"
    else
        [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
            source /usr/share/doc/fzf/examples/key-bindings.zsh
        [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && \
            source /usr/share/doc/fzf/examples/completion.zsh
    fi

    # Respect .gitignore and skip .git when listing candidates
    if has fd; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border=rounded --info=inline'

    # Preview file contents on Ctrl+T, directory trees on Alt+C
    if has bat; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
    elif has batcat; then
        export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:200 {}'"
    fi
    if has eza; then
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
    fi
fi

# ---------------------------------------------------------------------------
# zoxide - frecency-ranked cd. Replaces cd; `cdi` opens the interactive picker.
# ---------------------------------------------------------------------------
if has zoxide; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# ---------------------------------------------------------------------------
# atuin - searchable, synced shell history (takes over Ctrl+R from fzf).
# Up-arrow stays with zsh's own history so muscle memory is unaffected.
# ---------------------------------------------------------------------------
if has atuin; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# ---------------------------------------------------------------------------
# direnv - per-directory environments
# ---------------------------------------------------------------------------
has direnv && eval "$(direnv hook zsh)"

# ---------------------------------------------------------------------------
# mise - runtime version manager
# ---------------------------------------------------------------------------
has mise && eval "$(mise activate zsh)"

# ---------------------------------------------------------------------------
# Completions
# ---------------------------------------------------------------------------
# Static completions generated into zfunc/ by `make completions`; they are on
# fpath already (see .zshrc). Tools that only offer dynamic completion go here.
has uv && eval "$(uv generate-shell-completion zsh)"
has gh && eval "$(gh completion -s zsh)"
has glab && eval "$(glab completion -s zsh)"

# Third-party completion files, sourced only when present
[[ -f "${HOME}/.openclaw/completions/openclaw.zsh" ]] && \
    source "${HOME}/.openclaw/completions/openclaw.zsh"
[[ -s "${HOME}/.bun/_bun" ]] && source "${HOME}/.bun/_bun"

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------
# zsh-navigation-tools
zle -N znt-cd-widget
bindkey "^B" znt-cd-widget
zle -N znt-kill-widget
bindkey "^Y" znt-kill-widget

# Accept the autosuggestion with Ctrl+Space
bindkey '^ ' autosuggest-accept

# ---------------------------------------------------------------------------
# Command-not-found: prefer Debian's apt suggestions over Homebrew's handler.
# Homebrew installs its own handler, so this must be defined after brew init.
# ---------------------------------------------------------------------------
if [[ -x /usr/lib/command-not-found ]]; then
    command_not_found_handler() {
        /usr/lib/command-not-found -- "$1"
    }
fi
