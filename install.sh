#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly BACKUP_DIR="${SCRIPT_DIR}/backup"
readonly CONFIG_DIR="${HOME}/.config"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# shellcheck disable=SC2317
log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
# shellcheck disable=SC2317
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
# shellcheck disable=SC2317
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

# Install essentials
log_info "Installing essentials..."
if ! source "${SCRIPT_DIR}/bin/install_essentials.sh"; then
    log_error "Failed to install essentials"
    exit 1
fi

# User bin setup
log_info "Setting up ~/bin..."
mkdir -p "${HOME}/bin"
shopt -s nullglob
for script_path in "${SCRIPT_DIR}/bin/"*; do
    script_name="$(basename "${script_path}")"
    target="${HOME}/bin/${script_name}"

    if [[ -L "${target}" ]]; then
        log_info "  Skipping ${script_name} (already linked)"
    else
        ln -sf "${script_path}" "${target}"
        log_info "  Linked ${script_name}"
    fi
done

# Dotfiles symlinks
log_info "Linking dotfiles..."
readonly DOTFILES=(.zshrc)
for dotfile in "${DOTFILES[@]}"; do
    source_file="${SCRIPT_DIR}/${dotfile}"
    target_file="${HOME}/${dotfile}"
    backup_file="${BACKUP_DIR}/${dotfile}"

    if [[ -L "${target_file}" ]]; then
        log_info "  Removing existing symlink: ${dotfile}"
        rm -f "${target_file}"
    elif [[ -e "${target_file}" && ! -e "${backup_file}" ]]; then
        log_info "  Backing up existing ${dotfile}"
        mv "${target_file}" "${backup_file}"
    fi

    ln -sf "${source_file}" "${target_file}"
    log_info "  Linked ${dotfile}"
done

# Application configs
log_info "Linking application configs..."
mkdir -p "${CONFIG_DIR}"
readonly APPS=(ghostty)
for app in "${APPS[@]}"; do
    source_config="${SCRIPT_DIR}/config/${app}"
    target_config="${CONFIG_DIR}/${app}"
    backup_config="${BACKUP_DIR}/config-${app}"

    if [[ ! -d "${source_config}" ]]; then
        log_warn "  Config for ${app} not found, skipping"
        continue
    fi

    if [[ -e "${target_config}" && ! -L "${target_config}" ]]; then
        log_info "  Backing up ${app} config"
        mv "${target_config}" "${backup_config}"
    fi

    rm -f "${target_config}"
    ln -sf "${source_config}" "${target_config}"
    log_info "  Linked ${app} config"
done

# Git config
if command -v git &> /dev/null; then
    git config --global include.path "${SCRIPT_DIR}/.gitconfig"
    log_info "Configured git to include dotfiles .gitconfig"
else
    log_warn "Git not found, skipping git configuration"
fi

# Create default directories
mkdir -p "${HOME}/Projects" "${HOME}/Applications"

# Switch to zsh
if command -v zsh &> /dev/null; then
    zsh_path="$(command -v zsh)"
    current_shell="$(basename "${SHELL}")"

    if [[ "${current_shell}" != "zsh" ]]; then
        log_info "Changing default shell to zsh..."
        if ! chsh -s "${zsh_path}"; then
            log_error "Failed to change shell. Run manually: chsh -s ${zsh_path}"
        fi
    else
        log_info "Already using zsh"
    fi
else
    log_error "Zsh not found! Please install it first."
    exit 1
fi

echo ""
log_info "=== Installation complete! ==="
echo ""
echo "Next steps:"
echo "  1. Log out and back in for shell changes to take effect"
echo "  2. Select a Powerline/Nerd font for your terminal"
echo "  3. Run 'p10k configure' to set up your prompt"
echo ""
echo "To install extra goodies (Docker, gh, glab, batcat, etc.):"
echo "  ${SCRIPT_DIR}/bin/install_goodies.sh"
