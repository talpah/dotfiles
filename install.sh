#!/bin/bash

me=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Install essentials
source "${me}/bin/install_essentials.sh"

# User bin
mkdir -p "${HOME}/bin"
for f in $(ls ${me}/bin/*); do
  f=$(basename "${f}")
  # No overrides
  [ -L "${HOME}/bin/${f}" ] || ln -s "${me}/bin/${f}" "${HOME}/bin/${f}"
done

# Actual dot files :)
for f in .bash_aliases .bashrc .profile .venv; do
  if [[ -e "${me}/backup/${f}" ]]; then
    # Already backed up
    rm "${HOME}/${f}"
  else
    # Backup
    mv "${HOME}/${f}" "${me}/backup/${f}"
  fi
  ln -s "${me}/${f}" "${HOME}/${f}"
done

git config --global include.path "${me}/.gitconfig"

# Default virtualenv
export WORKON_HOME="${HOME}/VirtualEnv"


# Default tree
mkdir -p "${HOME}/Projects"
mkdir -p "${HOME}/Applications"
mkdir -p "${HOME}/VirtualEnv"

source "${HOME}/.bashrc"
echo "You should re-login to make available for all sessions"
echo "To install extra goodies run ${me}/bin/install_goodies.sh"
