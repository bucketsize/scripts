. ../common.sh

checkpkgs "opam"

[ -d ~/Programs ] || mkdir ~/Programs
updatelink ~/scripts/config/lspd/my ~/Programs/lspd
