#!/bin/sh

. ~/scripts/common.sh


if [ "" = "$(grep '\.local\/bin' ~/.bashrc | tr -d '\n')" ]; then
    echo "\n# --" >> ~/.bashrc
    echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
fi

createdir ~/.cache
createdir ~/.theme
createdir ~/.wlprs

. bspwm/setup.sh
. sxhkd/setup.sh
. dunst/setup.sh
. tint2/setup.sh
. picom/setup.sh
. compton/setup.sh
. Xresources/setup.sh
. nvim/setup.sh
. mpd/setup.sh
. mpv/setup.sh
#. frmad/setup.sh
#. mxctl/setup.sh

updatelink ~/scripts/bgfpid ~/.local/bin/bgfpid

# phase 2
# requirefiles "~/.luarocks/bin/frmad.cached
#  ~/.luarocks/bin/frmad.daemon 
#  ~/.luarocks/bin/mxctl.control"

