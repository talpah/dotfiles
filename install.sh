#!/bin/bash

me=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Install essentials
source "${me}/bin/install_essentials.sh"

# User bin
mkdir -p "${HOME}/bin"
[ -L "${HOME}/VirtualEnv" ] || ln -s "${me}/VirtualEnv" "${HOME}/VirtualEnv"
for f in $(ls ${me}/bin/*); do
  f=$(basename "${f}")
  # No overrides
  [ -L "${HOME}/bin/${f}" ] || ln -s "${me}/bin/${f}" "${HOME}/bin/${f}"
done

# Actual dot files :)
for f in .bashrc .gitignore .profile .venv; do
  if [[ -f "${me}/backup/${f}" ]]; then
    # Already backed up
    rm "${HOME}/${f}"
  else
    # Backup
    mv "${HOME}/${f}" "${me}/backup/${f}"
  fi
  ln -s "${me}/${f}" "${HOME}/${f}"
done

# Default virtualenv
virtualenv "${HOME}/VirtualEnv/local"

# Default tree
mkdir -p "${HOME}/Projects"
mkdir -p "${HOME}/Applications"

echo "You should re-login or source .bashrc"
