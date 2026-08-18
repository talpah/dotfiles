# ============================================================================
# Environment
# ============================================================================

export LANG=en_US.UTF-8
export EDITOR=vim
export VISUAL="${EDITOR}"

# Pager: bat when available, plain less otherwise
if command -v bat &> /dev/null; then
    export PAGER='bat --plain --paging=always'
    export MANPAGER="sh -c 'col -bx | bat --language man --plain --paging=always'"
    export MANROFFOPT='-c'
elif command -v batcat &> /dev/null; then
    export PAGER='batcat --plain --paging=always'
    export MANPAGER="sh -c 'col -bx | batcat --language man --plain --paging=always'"
    export MANROFFOPT='-c'
else
    export PAGER='less -FRX'
fi

export LESS='-FRX --mouse'

# SOPS encryption
[[ -f "${HOME}/.sops/age.agekey" ]] && export SOPS_AGE_KEY_FILE="${HOME}/.sops/age.agekey"

# Docker: BuildKit and compose v2 defaults
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Python: never write .pyc into the source tree, unbuffered output
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# uv: keep the tool cache out of $HOME clutter
export UV_LINK_MODE=copy

# Local environment overrides (kept out of the repo)
[[ -f "${HOME}/.zshenv.local" ]] && source "${HOME}/.zshenv.local"
