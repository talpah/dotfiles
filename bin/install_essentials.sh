#!/usr/bin/env bash
set -euo pipefail

# Colors (may be inherited from parent script)
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Check if running on supported system
if ! command -v apt-get &> /dev/null; then
    log_error "This script requires apt-get (Debian/Ubuntu)"
    exit 1
fi

# Install essential packages
log_info "Installing essential packages..."
sudo apt-get update
sudo apt-get install -y curl tree git zsh fonts-powerline

# Install oh-my-zsh if not already installed
readonly OMZ_DIR="${HOME}/.oh-my-zsh"
if [[ ! -d "${OMZ_DIR}" ]]; then
    log_info "Installing oh-my-zsh..."

    # Download installer to temp file (safer than curl | sh)
    OMZ_INSTALLER="$(mktemp)"
    readonly OMZ_INSTALLER
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "${OMZ_INSTALLER}"

    # Run with --unattended to prevent interactive prompts
    sh "${OMZ_INSTALLER}" --unattended || true
    rm -f "${OMZ_INSTALLER}"

    log_info "oh-my-zsh installed"
else
    log_info "oh-my-zsh already installed"
fi

# Install powerlevel10k theme
readonly P10K_DIR="${OMZ_DIR}/custom/themes/powerlevel10k"
if [[ ! -d "${P10K_DIR}" ]]; then
    log_info "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_DIR}"
    log_info "powerlevel10k installed"
else
    log_info "powerlevel10k already installed, updating..."
    git -C "${P10K_DIR}" pull --quiet || log_warn "Failed to update powerlevel10k"
fi

# Install custom zsh plugins referenced by .zshrc
readonly PLUGIN_DIR="${OMZ_DIR}/custom/plugins"
mkdir -p "${PLUGIN_DIR}"

install_zsh_plugin() {
    local name="$1" url="$2" dir="${PLUGIN_DIR}/$1"

    if [[ ! -d "${dir}" ]]; then
        log_info "Installing ${name}..."
        git clone --depth=1 "${url}" "${dir}"
    else
        log_info "${name} already installed, updating..."
        git -C "${dir}" pull --quiet || log_warn "Failed to update ${name}"
    fi
}

install_zsh_plugin zsh-autosuggestions \
    https://github.com/zsh-users/zsh-autosuggestions.git
install_zsh_plugin zsh-syntax-highlighting \
    https://github.com/zsh-users/zsh-syntax-highlighting.git

log_info "Essentials installation complete"
