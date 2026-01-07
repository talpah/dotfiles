#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly BACKUP_DIR="${SCRIPT_DIR}/backup"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# shellcheck disable=SC2317
log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
# shellcheck disable=SC2317
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

# Confirmation prompt
echo -e "${YELLOW}This will remove dotfiles symlinks and restore backups.${NC}"
echo ""
read -rp "Are you sure you want to continue? (yes/no): " confirm
if [[ "${confirm}" != "yes" ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""

# Restore dotfiles
log_info "Restoring dotfiles..."
readonly DOTFILES=(.zshrc)
for dotfile in "${DOTFILES[@]}"; do
    backup_file="${BACKUP_DIR}/${dotfile}"
    target_file="${HOME}/${dotfile}"

    if [[ -L "${target_file}" ]]; then
        rm -f "${target_file}"
        log_info "  Removed symlink: ${dotfile}"
    fi

    if [[ -e "${backup_file}" ]]; then
        mv "${backup_file}" "${target_file}"
        log_info "  Restored ${dotfile} from backup"
    fi
done

# Restore config directories
log_info "Restoring application configs..."
readonly APPS=(ghostty)
for app in "${APPS[@]}"; do
    target_config="${HOME}/.config/${app}"
    backup_config="${BACKUP_DIR}/config-${app}"

    if [[ -L "${target_config}" ]]; then
        rm -f "${target_config}"
        log_info "  Removed ${app} config symlink"
    fi

    if [[ -d "${backup_config}" ]]; then
        mv "${backup_config}" "${target_config}"
        log_info "  Restored ${app} config from backup"
    fi
done

# Clean up bin symlinks
log_info "Cleaning up ~/bin symlinks..."
shopt -s nullglob
for script_path in "${SCRIPT_DIR}/bin/"*; do
    script_name="$(basename "${script_path}")"
    link="${HOME}/bin/${script_name}"

    if [[ -L "${link}" ]] && [[ "$(readlink "${link}")" == "${script_path}" ]]; then
        rm -f "${link}"
        log_info "  Removed: ${script_name}"
    fi
done

# Remove git config include
if command -v git &> /dev/null; then
    git config --global --unset include.path 2>/dev/null || true
    log_info "Removed git config include"
fi

echo ""
read -rp "Remove dotfiles directory ${SCRIPT_DIR}? (yes/no): " remove_dir
if [[ "${remove_dir}" == "yes" ]]; then
    cd "${HOME}"
    rm -rf "${SCRIPT_DIR}"
    log_info "Dotfiles directory removed"
else
    log_info "Dotfiles directory kept at ${SCRIPT_DIR}"
fi

echo ""
log_info "Uninstall complete!"
