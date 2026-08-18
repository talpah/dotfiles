# ============================================================================
# Message of the day
# ============================================================================
# Loaded last so it prints after the rest of the shell is configured.

# Cool apps reminder - shown once per day in a new interactive shell.
# Regenerate the cache with: cool-apps-refresh --refresh
() {
    [[ -o interactive ]] || return 0

    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/cool-apps-motd.txt"
    local stamp="${XDG_CACHE_HOME:-$HOME/.cache}/cool-apps-shown-date"
    local today

    [[ -f "${cache}" ]] || return 0

    today="$(date +%Y-%m-%d)"
    [[ "$(command cat "${stamp}" 2>/dev/null)" == "${today}" ]] && return 0

    # `command cat`: a bare cat resolves to the bat alias from 20-aliases.zsh
    command cat "${cache}"
    print -r -- "${today}" > "${stamp}"
}
