# ============================================================================
# PATH construction
# ============================================================================
# Loaded first: later modules probe for tools with `has`, so everything
# must already be reachable by the time 30-tools.zsh runs.

# has <cmd> - true only when <cmd> is a real external binary.
# Do NOT use `command -v` for this: in zsh it also matches aliases and
# functions, and oh-my-zsh's common-aliases plugin defines `fd` and `duf`
# as fallback aliases exactly when those binaries are absent. Probing with
# `command -v` therefore reports them as installed and produces aliases
# pointing at commands that do not exist.
zmodload -F zsh/parameter p:commands 2>/dev/null
has() { (( ${+commands[$1]} )) }

# Add to PATH only if the directory exists and is not already present
add_to_path() {
    [[ -d "$1" ]] || return 0
    case ":${PATH}:" in
        *":$1:"*) return 0 ;;
        *) export PATH="$1:${PATH}" ;;
    esac
}

# Homebrew is initialised in .zshrc, before oh-my-zsh runs compinit, so that
# brew-provided completions land on fpath in time. By the time this module
# loads, fd/rg/fzf/zoxide/eza/delta are already on PATH.

# User binaries
add_to_path "${HOME}/bin"
add_to_path "${HOME}/.local/bin"
add_to_path "${HOME}/.npm-global/bin"
add_to_path "${HOME}/.cargo/bin"

# System administration tools (hwinfo, fdisk, etc.)
add_to_path /usr/sbin
add_to_path /sbin

# Language and tool managers
if [[ -d "${HOME}/.bun" ]]; then
    export BUN_INSTALL="${HOME}/.bun"   # bun reads this for self-update and global installs
    add_to_path "${BUN_INSTALL}/bin"
fi
add_to_path "${HOME}/go/bin"

# AI tooling
add_to_path "${HOME}/.lmstudio/bin"
add_to_path "${HOME}/.opencode/bin"

# Android SDK
if [[ -d "${HOME}/android-sdk" ]]; then
    export ANDROID_HOME="${HOME}/android-sdk"
    add_to_path "${ANDROID_HOME}/cmdline-tools/latest/bin"
    add_to_path "${ANDROID_HOME}/platform-tools"
fi
