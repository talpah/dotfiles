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

echo ""

# File existence tests
echo "=== File Existence ==="
run_test ".zshrc exists" "[[ -f .zshrc ]]"
run_test ".gitconfig exists" "[[ -f .gitconfig ]]"
run_test "backup directory exists" "[[ -d backup ]]"
run_test "config/ghostty exists" "[[ -d config/ghostty ]]"
run_test "zfunc directory exists" "[[ -d zfunc ]]"

echo ""

# Shellcheck tests (if available)
if command -v shellcheck &> /dev/null; then
    echo "=== ShellCheck ==="
    run_test "shellcheck install.sh" "shellcheck -x install.sh"
    run_test "shellcheck uninstall.sh" "shellcheck -x uninstall.sh"
    run_test "shellcheck install_essentials.sh" "shellcheck -x bin/install_essentials.sh"
    run_test "shellcheck install_goodies.sh" "shellcheck -x bin/install_goodies.sh"
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
