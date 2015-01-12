#!/bin/bash

me=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "${me}/bin/install_essentials.sh"

mkdir -p "${HOME}/bin"
[ -L "${HOME}/VirtualEnv" ] || ln -s "${me}/VirtualEnv" "${HOME}/VirtualEnv"

for f in $(ls ${me}/bin/*); do
  f=$(basename "${f}")
  [ -L "${HOME}/bin/${f}" ] || ln -s "${me}/bin/${f}" "${HOME}/bin/${f}"
done

for f in .bashrc .gitignore .profile .venv; do
  rm "${HOME}/${f}"
  ln -s "${me}/${f}" "${HOME}/${f}"
done

virtualenv "${HOME}/VirtualEnv/local"

echo "You should re-login or source .bashrc"
