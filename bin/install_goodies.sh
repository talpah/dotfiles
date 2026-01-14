#!/usr/bin/env bash
set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect OS
if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect OS. /etc/os-release not found."
    exit 1
fi

source /etc/os-release
readonly OS_ID="${ID}"
readonly OS_CODENAME="${VERSION_CODENAME:-}"

# Pop!_OS is Ubuntu-based, so use ubuntu for repository URLs
if [[ "${OS_ID}" == "pop" ]]; then
    readonly REPO_OS="ubuntu"
elif [[ "${OS_ID}" == "ubuntu" || "${OS_ID}" == "debian" ]]; then
    readonly REPO_OS="${OS_ID}"
else
    log_error "This script only supports Ubuntu, Debian, and Pop!_OS"
    exit 1
fi

if [[ -z "${OS_CODENAME}" ]]; then
    log_error "Cannot determine OS codename"
    exit 1
fi

log_info "Detected: ${NAME} ${VERSION} (${OS_CODENAME})"

# Setup repositories
log_info "Setting up package repositories..."

sudo install -m 0755 -d /etc/apt/keyrings /usr/share/keyrings

# GitHub CLI repo
if [[ ! -f "/usr/share/keyrings/githubcli-archive-keyring.gpg" ]]; then
    log_info "  Adding GitHub CLI repository..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
else
    log_info "  GitHub CLI repository already configured"
fi

# GitLab CLI repo
if [[ ! -f "/usr/share/keyrings/gitlab-cli-archive-keyring.gpg" ]]; then
    log_info "  Adding GitLab CLI repository..."
    curl -fsSL https://packages.gitlab.com/gpg.key \
        | sudo gpg --dearmor -o /usr/share/keyrings/gitlab-cli-archive-keyring.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlab-cli-archive-keyring.gpg] https://packages.gitlab.com/gitlab/glab-cli/${REPO_OS} ${OS_CODENAME} main" \
        | sudo tee /etc/apt/sources.list.d/gitlab-cli.list > /dev/null
else
    log_info "  GitLab CLI repository already configured"
fi

# Docker repo
if [[ ! -f "/etc/apt/keyrings/docker.gpg" ]]; then
    log_info "  Adding Docker repository..."
    curl -fsSL "https://download.docker.com/linux/${REPO_OS}/gpg" \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${REPO_OS} ${OS_CODENAME} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    log_info "  Docker repository already configured"
fi

# Install packages
log_info "Installing packages..."
sudo apt-get update

readonly PACKAGES=(
    ca-certificates curl gnupg lsb-release
    tilix mc btop vim build-essential
    bat gh glab
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
)

if ! sudo apt-get install -y "${PACKAGES[@]}"; then
    log_error "Package installation failed"
    exit 1
fi

# Verify critical packages
log_info "Verifying installation..."
for pkg in docker-ce gh glab bat; do
    if dpkg -l "${pkg}" &> /dev/null; then
        log_info "  ✓ ${pkg}"
    else
        log_warn "  ✗ ${pkg} may not have installed correctly"
    fi
done

# Add user to docker group
if ! groups | grep -q docker; then
    sudo usermod -aG docker "${USER}"
    log_info "Added ${USER} to docker group"
else
    log_info "Already in docker group"
fi

echo ""
log_info "=== All goodies installed! ==="
log_warn "Log out and back in for docker group membership to take effect."
echo ""
echo "Verify with:"
echo "  docker --version"
echo "  gh --version"
echo "  glab --version"
echo "  bat --version"
