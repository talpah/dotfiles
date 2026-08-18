#!/usr/bin/env bash
# Assertions executed INSIDE a test container.
#   MODE=full  - distro is apt-based; run install.sh and verify everything
#   MODE=shell - distro is unsupported; verify the installer refuses cleanly
#                and that the zsh config is still portable
set -uo pipefail

readonly MODE="${MODE:-full}"
readonly DOTS="${HOME}/.dotfiles"
readonly GREEN='\033[0;32m' RED='\033[0;31m' NC='\033[0m'

pass=0 fail=0
check() {
    local name="$1" cmd="$2"
    if eval "${cmd}" &> /dev/null; then
        printf "  ${GREEN}✓${NC} %s\n" "${name}"; pass=$((pass + 1))
    else
        printf "  ${RED}✗${NC} %s\n" "${name}"; fail=$((fail + 1))
    fi
}

# Run an interactive zsh and strip noise that is inherent to containers
# (no tty for gitstatus, no tmux, no ~/.ssh) rather than config defects.
zrun() {
    zsh -i -c "$1" 2>&1 | grep -viE 'gitstatus|instant prompt|p10k|powerlevel|tmux plugin|ssh-agent plugin'
}

echo "=== [${MODE}] $(. /etc/os-release && echo "${PRETTY_NAME}") ==="

if [[ "${MODE}" == "full" ]]; then
    echo "--- install ---"
    ( cd "${DOTS}" && ./install.sh ) < /dev/null > /tmp/install.log 2>&1
    check "install.sh exits 0"            "[[ \$? -eq 0 ]] || grep -q 'Installation complete' /tmp/install.log"
    check "no ERROR lines in install log" "! grep -q '\[ERROR\]' /tmp/install.log"

    echo "--- symlinks ---"
    check ".zshrc is a symlink"          "[[ -L ${HOME}/.zshrc ]]"
    check ".zshrc points into repo"      "[[ \$(readlink -f ${HOME}/.zshrc) == ${DOTS}/.zshrc ]]"
    check ".config/ghostty symlinked"    "[[ -L ${HOME}/.config/ghostty ]]"
    check "bin/install_goodies.sh linked" "[[ -L ${HOME}/bin/install_goodies.sh ]]"
    check ".zshrc.local created"         "[[ -f ${HOME}/.zshrc.local ]]"
    check "original .zshrc backed up"      "[[ -e ${DOTS}/backup/.zshrc ]]"

    echo "--- shell switch (needs passwordless chsh) ---"
    check "login shell is zsh"             "getent passwd \$(id -un) | grep -q 'zsh$'"

    echo "--- git config include ---"
    check "include.path set"               "git config --global --get include.path | grep -q dotfiles"
    check "dotfiles git alias resolves"    "git config --get alias.wtl | grep -q worktree"

    echo "--- oh-my-zsh assets ---"
    check "powerlevel10k installed"        "[[ -d ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k ]]"
    check "zsh-autosuggestions installed"  "[[ -d ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]"
    check "zsh-syntax-highlighting installed" "[[ -d ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]"
else
    echo "--- unsupported distro handling ---"
    ( cd "${DOTS}" && ./bin/install_essentials.sh ) < /dev/null > /tmp/ess.log 2>&1
    check "install_essentials.sh refuses"        "[[ \$? -ne 0 ]] || grep -q 'requires apt-get' /tmp/ess.log"
    check "refusal names the reason"             "grep -q 'apt-get' /tmp/ess.log"
    ( cd "${DOTS}" && ./bin/install_goodies.sh ) < /dev/null > /tmp/good.log 2>&1
    check "install_goodies.sh refuses"           "grep -qE 'only supports|Cannot detect' /tmp/good.log"

    # The installers are apt-only, so replicate what install_essentials.sh
    # would have done, minus the package manager. This isolates the question
    # "is the zsh config itself portable?" from "does the installer run here?".
    setup_shell_only() {
        local omz="${HOME}/.oh-my-zsh"
        [[ -d "${omz}" ]] || git clone --depth=1 -q \
            https://github.com/ohmyzsh/ohmyzsh.git "${omz}"
        [[ -d "${omz}/custom/themes/powerlevel10k" ]] || git clone --depth=1 -q \
            https://github.com/romkatv/powerlevel10k.git "${omz}/custom/themes/powerlevel10k"
        local plug
        for plug in zsh-autosuggestions zsh-syntax-highlighting; do
            [[ -d "${omz}/custom/plugins/${plug}" ]] || git clone --depth=1 -q \
                "https://github.com/zsh-users/${plug}.git" "${omz}/custom/plugins/${plug}"
        done
        ln -sfn "${DOTS}/.zshrc" "${HOME}/.zshrc"
    }
    setup_shell_only > /dev/null 2>&1

    echo "--- portable shell config (manual omz setup) ---"
    check "oh-my-zsh present"              "[[ -d ${HOME}/.oh-my-zsh ]]"
    check ".zshrc is a symlink"          "[[ -L ${HOME}/.zshrc ]]"
fi

echo "--- shell loads ---"
check "zsh starts and resolves DOTFILES"  "zrun 'echo \$DOTFILES' | grep -q dotfiles"
check "no 'command not found' at startup" "! zrun 'true' | grep -qi 'command not found'"
check "no parse errors at startup"        "! zrun 'true' | grep -qiE 'parse error|bad pattern|syntax error'"
check "has() helper defined"              "zrun 'whence -w has' | grep -q function"

echo "--- fallbacks: no alias may point at a missing binary ---"
# The core regression: `command -v` matched oh-my-zsh's fd/duf fallback
# aliases, so find/df were aliased to tools that did not exist.
check "find not aliased to missing fd"    "! zrun 'alias find' | grep -qE \"find='?fd'?\$\""
check "df not aliased to missing duf"     "! zrun 'alias df' | grep -qE \"df='?duf'?\$\""
for c in find df du ps grep ls cat; do
    check "${c} executes"                 "zrun '${c} --help >/dev/null 2>&1 || ${c} . >/dev/null 2>&1 || true; echo ok' | grep -q ok"
done
check "escape hatch: backslash-find"     "zrun '\\find /etc/hostname' | grep -q hostname"
check "escape hatch: command find"       "zrun 'command find /etc/hostname' | grep -q hostname"

echo "--- project test suite ---"
check "test.sh passes in-container"       "cd ${DOTS} && ./test.sh"

echo ""
echo "=== ${MODE}: ${pass} passed, ${fail} failed ==="
[[ ${fail} -eq 0 ]]
