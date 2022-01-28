source ../common.sh
checkpkgs "mpd mpc"
createdir ~/.mpd
updatelink ~/scripts/config/mpd/my ~/.config/mpd
