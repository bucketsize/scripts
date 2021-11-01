echo "setup $(pwd) ..."

checkpkgs "git libssl make urxvt xrandr fzy wmctrl pactl"
githubfetch bucketsize/minilib
githubfetch bucketsize/mxctl

ipwd=$(pwd)
arch=$(lscpu | grep -Po "(?<=Architecture:).+" |  tr -d " ")
LIBDIR=/usr/lib/$arch-linux-gnu
cd ~/minilib && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR
cd ~/mxctl && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR 
cd $ipwd

if [ -d ~/.config/mxctl ]; then
    echo "[~/.config/mxctl] already present"
else
    createdir ~/.config/mxctl
    cp ~/scripts/config/mxctl/my/config ~/.config/mxctl/
fi
