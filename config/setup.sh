#!/bin/sh

. ~/scripts/common.sh


if [ "" == $(grep "\.local\/bin" ~/.bashrc | tr -d "\n") ]; then
    echo "\n# --"
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
. frmad/setup.sh
. mxctl/setup.sh
. nvim/setup.sh

# phase 2
# requirefiles "~/.luarocks/bin/frmad.cached
#  ~/.luarocks/bin/frmad.daemon 
#  ~/.luarocks/bin/mxctl.control"

