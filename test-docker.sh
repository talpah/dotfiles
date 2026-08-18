#!/usr/bin/env bash
# Install-and-verify the dotfiles inside clean containers.
#
#   ./test-docker.sh                 # all distros
#   ./test-docker.sh debian          # a subset
#   KEEP=1 ./test-docker.sh debian   # keep containers for poking at
#
# Each container gets passwordless sudo AND passwordless chsh, so the whole
# install path is exercised - including the shell switch, which silently
# fails under a normal container user.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly DOCKER_DIR="${SCRIPT_DIR}/test/docker"
readonly TAG_PREFIX="dotfiles-test"

readonly GREEN='\033[0;32m' RED='\033[0;31m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
log()  { echo -e "${BLUE}==>${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Every image here is apt-based; the installers support nothing else.
readonly DISTROS=(debian ubuntu)

if ! command -v docker &> /dev/null; then
    err "docker not found"; exit 1
fi
if ! docker info &> /dev/null; then
    err "cannot talk to the docker daemon (is it running? are you in the docker group?)"
    exit 1
fi

targets=("$@")
if [[ ${#targets[@]} -eq 0 ]]; then
    targets=("${DISTROS[@]}")
fi

for t in "${targets[@]}"; do
    if [[ ! -f "${DOCKER_DIR}/Dockerfile.${t}" ]]; then
        err "unknown distro '${t}'. Known: ${DISTROS[*]}"; exit 2
    fi
done

# Ship the working tree, not HEAD, so uncommitted fixes are testable. Excludes
# match what a fresh clone would lack (gitignore is '*', so generated files and
# backups are never committed).
log "Packaging working tree..."
tar --exclude-vcs \
    --exclude='./backup/.zshrc' \
    --exclude='./backup/.zshrc.*' \
    --exclude='./zfunc/_*' \
    --exclude='./test/docker/dotfiles.tar' \
    --transform='s|^\.|dotfiles|' \
    -cf "${DOCKER_DIR}/dotfiles.tar" -C "${SCRIPT_DIR}" . 2>/dev/null
echo "    $(tar -tf "${DOCKER_DIR}/dotfiles.tar" | grep -vc '/$') files"

declare -A RESULT
overall=0

for distro in "${targets[@]}"; do
    image="${TAG_PREFIX}-${distro}"
    container="${TAG_PREFIX}-${distro}-run"

    echo ""
    log "${distro}"

    if ! docker build -q -t "${image}" -f "${DOCKER_DIR}/Dockerfile.${distro}" "${DOCKER_DIR}" > /dev/null; then
        err "build failed for ${distro}"
        RESULT[$distro]="BUILD FAILED"; overall=1; continue
    fi

    docker rm -f "${container}" &> /dev/null || true
    if docker run --name "${container}" "${image}" \
            bash /home/tester/.dotfiles/test/docker/assert.sh; then
        RESULT[$distro]="PASS"
    else
        RESULT[$distro]="FAIL"; overall=1
    fi

    if [[ -z "${KEEP:-}" ]]; then
        docker rm -f "${container}" &> /dev/null || true
    else
        warn "kept container ${container} (docker exec -it ${container} zsh)"
    fi
done

rm -f "${DOCKER_DIR}/dotfiles.tar"

echo ""
echo "=============================="
echo " Docker matrix"
echo "=============================="
for distro in "${targets[@]}"; do
    r="${RESULT[$distro]:-SKIPPED}"
    if [[ "${r}" == "PASS" ]]; then
        echo -e " ${GREEN}✓${NC} ${distro}"
    else
        echo -e " ${RED}✗${NC} ${distro} - ${r}"
    fi
done
echo ""
[[ ${overall} -eq 0 ]] && echo -e "${GREEN}All images passed!${NC}" || echo -e "${RED}Some images failed!${NC}"
exit "${overall}"
