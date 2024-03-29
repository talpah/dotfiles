#!/bin/bash

me=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

for f in .zshrc .venv; do
  if [[ -e "${me}/backup/${f}" ]]; then
    echo "Restoring ${f}"
    rm "${HOME}/${f}"
    mv "${me}/backup/${f}" "${HOME}/${f}"
  fi
done

echo "Removing self"
(rm -rf "${me}")
