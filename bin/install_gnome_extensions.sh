#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

wget -O "${DIR}/shell-extension-install" https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnome-extension/shell-extension-install
chmod +x "${DIR}/shell-extension-install"
GNOMEVERSION=$(gnome-shell --version | sed 's/gnome shell //ig')

for e in 307 584 517 696 885 750 905 779 708 759 817 980 945 1015; do
    ${DIR}/shell-extension-install "$GNOMEVERSION" "$e"
done
