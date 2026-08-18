# ============================================================================
# PATH construction
# ============================================================================
# Loaded first: later modules probe for tools with `command -v`, so everything
# must already be reachable by the time 30-tools.zsh runs.

# Add to PATH only if the directory exists and is not already present
add_to_path() {
    [[ -d "$1" ]] || return 0
    case ":${PATH}:" in
        *":$1:"*) return 0 ;;
        *) export PATH="$1:${PATH}" ;;
    esac
}

# Homebrew (Linuxbrew) - first, it provides fd/rg/fzf/zoxide/eza/delta
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "${HOME}/.linuxbrew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
fi

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
