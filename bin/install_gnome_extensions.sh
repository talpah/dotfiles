#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

wget -O "${DIR}/gnomeshell-extension-manage" https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage
chmod +x "${DIR}/gnomeshell-extension-manage"
GNOMEVERSION=$(gnome-shell --version | sed 's/gnome shell //ig')

for e in 307 584 517 696 885 750 905 779 708 759 817 980 945 979 1015; do
    ${DIR}/gnomeshell-extension-manage --install --version "$GNOMEVERSION" --extension-id  "$e"
done
