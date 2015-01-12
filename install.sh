#!/bin/bash

me = $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

mkdir -p "${HOME}/bin"
[ -l "${HOME}/VirtualEnv" ] || ln -s "${me}/VirtualEnv" "${HOME}/VirtualEnv"

for f in bin/*; do
  [ -l "${HOME}/${f}" ] || ln -s "${me}/${f}" "${HOME}/${f}"
done

for f in .bashrc .gitignore .profile .venv; do
  rm "${HOME}/${f}"
  ln -s "${me}/${f}" "${HOME}/${f}"
done
