#!/usr/bin/env bash
set -uo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    test_count=$((test_count + 1))

    if eval "${test_command}" &>/dev/null; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} ${test_name}"
        fail_count=$((fail_count + 1))
    fi
}

echo "Running dotfiles tests..."
echo ""

# Syntax tests
echo "=== Syntax Checks ==="
run_test "install.sh syntax" "bash -n install.sh"
run_test "uninstall.sh syntax" "bash -n uninstall.sh"
run_test "install_essentials.sh syntax" "bash -n bin/install_essentials.sh"
run_test "install_goodies.sh syntax" "bash -n bin/install_goodies.sh"
run_test "test-docker.sh syntax" "bash -n test-docker.sh"
run_test "docker assert.sh syntax" "bash -n test/docker/assert.sh"

echo ""

# Zsh syntax tests
if command -v zsh &> /dev/null; then
    echo "=== Zsh Syntax ==="
    run_test ".zshrc syntax" "zsh -n .zshrc"
    for module in zsh/*.zsh; do
        run_test "$(basename "${module}") syntax" "zsh -n '${module}'"
    done
    echo ""
else
    echo -e "${YELLOW}[SKIP]${NC} zsh not installed"
    echo ""
fi

# File existence tests
echo "=== File Existence ==="
run_test ".zshrc exists" "[[ -f .zshrc ]]"
run_test ".gitconfig exists" "[[ -f .gitconfig ]]"
run_test "backup directory exists" "[[ -d backup ]]"
run_test "config/ghostty exists" "[[ -d config/ghostty ]]"
run_test "zfunc directory exists" "[[ -d zfunc ]]"
run_test "zsh module directory exists" "[[ -d zsh ]]"
run_test "zsh modules present" "compgen -G 'zsh/*.zsh' > /dev/null"

echo ""

# Config validity
echo "=== Config Validity ==="
run_test ".gitconfig parses" "git config --list --file .gitconfig"
run_test "ghostty config non-empty" "[[ -s config/ghostty/config ]]"
run_test ".zshrc loads modules" "grep -q 'zsh/\*\.zsh' .zshrc"
run_test ".zshrc sources local overrides" "grep -q 'zshrc.local' .zshrc"
# /home/linuxbrew is a fixed system path, not a user home - exclude it
run_test "no hardcoded user home paths" \
    "! grep -rn '/home/' zsh/ .zshrc | grep -v '/home/linuxbrew'"

# `command -v` matches aliases and functions in zsh, so tool probes must use
# the `has` helper (binary-only). Comments explaining this are exempt.
run_test "tool probes use has(), not command -v" \
    "! grep -rn 'command -v' zsh/ | grep -v '^zsh/00-path.zsh:[0-9]*:#'"

echo ""

# Shellcheck tests (if available)
if command -v shellcheck &> /dev/null; then
    echo "=== ShellCheck ==="
    run_test "shellcheck install.sh" "shellcheck -x install.sh"
    run_test "shellcheck uninstall.sh" "shellcheck -x uninstall.sh"
    run_test "shellcheck install_essentials.sh" "shellcheck -x bin/install_essentials.sh"
    run_test "shellcheck install_goodies.sh" "shellcheck -x bin/install_goodies.sh"
    run_test "shellcheck test-docker.sh" "shellcheck -x test-docker.sh"
    run_test "shellcheck docker assert.sh" "shellcheck -x test/docker/assert.sh"
    echo ""
else
    echo -e "${YELLOW}[SKIP]${NC} shellcheck not installed (apt install shellcheck)"
    echo ""
fi

# Summary
echo "=== Summary ==="
echo "Tests: ${test_count}, Passed: ${pass_count}, Failed: ${fail_count}"

if [[ ${fail_count} -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
