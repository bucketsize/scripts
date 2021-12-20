. ../../common.sh
checkpkgs "nvim"

[ -d my/plugged ] ||\
	([ -f my/plug.tgz ] && tar -xzf my/plug.tgz -C my)

updatelink ~/scripts/config/nvim/my ~/.config/nvim
updatelink ~/scripts/tvim ~/.local/bin/tvim
