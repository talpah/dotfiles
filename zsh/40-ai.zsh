# ============================================================================
# AI tooling
# ============================================================================

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
if command -v claude &> /dev/null; then
    alias cc='claude'
    alias ccy='claude --dangerously-skip-permissions'
    alias ccr='claude --resume'
    alias ccc='claude --continue'
    alias ccp='claude -p'                      # one-shot, print and exit

    # Backwards-compatible names
    alias cc-yolo='claude --dangerously-skip-permissions'
    alias cc-resume='claude --resume'
    alias cc-continue='claude --continue'

    # Run claude against a local model served by LM Studio
    cc-local() {
        ANTHROPIC_BASE_URL=http://localhost:1234 \
        ANTHROPIC_AUTH_TOKEN=lmstudio \
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
        claude "$@"
    }

    # Run claude against a local model served by Ollama
    cc-ollama() {
        ANTHROPIC_BASE_URL=http://localhost:11434 \
        ANTHROPIC_AUTH_TOKEN="${OLLAMA_API_KEY:-ollama-local}" \
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
        claude "$@"
    }

    # ccw <branch> [claude args...]
    # Create a git worktree for <branch> under ../<repo>-worktrees/ and open
    # claude inside it. Keeps the main clone untouched while agents work.
    ccw() {
        if [[ -z "$1" ]]; then
            print -u2 "usage: ccw <branch> [claude args...]"
            return 2
        fi

        local branch="$1"; shift
        local repo_root
        repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
            print -u2 "ccw: not inside a git repository"
            return 1
        }

        local tree_dir="${repo_root:h}/${repo_root:t}-worktrees/${branch//\//-}"

        if [[ -d "${tree_dir}" ]]; then
            print "ccw: reusing existing worktree ${tree_dir}"
        elif git -C "${repo_root}" show-ref --verify --quiet "refs/heads/${branch}"; then
            git -C "${repo_root}" worktree add "${tree_dir}" "${branch}" || return 1
        else
            git -C "${repo_root}" worktree add -b "${branch}" "${tree_dir}" || return 1
        fi

        (cd "${tree_dir}" && claude "$@")
    }

    # cx [file|-] ... - pipe files (or stdin) into claude as context.
    # Examples: cx src/app.py "explain the retry logic"
    #           kubectl logs pod | cx - "what is failing here?"
    cx() {
        local -a files
        local prompt=""

        while (( $# )); do
            if [[ "$1" == "-" || -f "$1" ]]; then
                files+=("$1")
            else
                prompt="$*"
                break
            fi
            shift
        done

        if (( ${#files} == 0 )); then
            print -u2 "usage: cx <file|-> [more files...] [prompt]"
            return 2
        fi

        {
            local f
            for f in "${files[@]}"; do
                if [[ "$f" == "-" ]]; then
                    print -- "--- stdin ---"
                    cat
                else
                    print -- "--- ${f} ---"
                    command cat "$f"
                fi
            done
        } | claude -p "${prompt:-Explain this.}"
    }

    # gdc [git diff args] - send a diff to claude for review
    gdc() {
        local diff
        diff="$(git diff "$@")"
        if [[ -z "${diff}" ]]; then
            print -u2 "gdc: no changes to review"
            return 1
        fi
        print -r -- "${diff}" | claude -p \
            "Review this diff. Flag correctness bugs first, then simplifications. Be terse."
    }
fi

# ---------------------------------------------------------------------------
# Other agent CLIs
# ---------------------------------------------------------------------------
command -v openclaw &> /dev/null && alias oc='openclaw'
command -v crush    &> /dev/null && alias cr='crush'
command -v opencode &> /dev/null && alias ocd='opencode'

# ---------------------------------------------------------------------------
# Local model servers
# ---------------------------------------------------------------------------
export OLLAMA_API_KEY="${OLLAMA_API_KEY:-ollama-local}"

# ai-models - list what the local backends currently serve
ai-models() {
    if command -v lms &> /dev/null; then
        print -P "%F{cyan}LM Studio%f"
        lms ls 2>/dev/null || print "  (server not running)"
    fi
    if command -v ollama &> /dev/null; then
        print -P "%F{cyan}Ollama%f"
        ollama list 2>/dev/null || print "  (server not running)"
    fi
}
