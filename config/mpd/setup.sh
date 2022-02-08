. ../common.sh
checkpkgs "mpd mpc"
createdir ~/.mpd
updatelink ~/scripts/config/mpd/my ~/.config/mpd
echo "going to disable automatic root start of mpd:..."
sudo systemctl disable mpd
