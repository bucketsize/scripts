githubfetch notandy/ympd

if [ ! -f ~/.local/bin/ympd ]; then
    ipwd=$(pwd)
    arch=$(lscpu | grep -Po "(?<=Architecture:).+" |  tr -d " ")
    LIBDIR=/usr/lib/$arch-linux-gnu
    cd ~/ympd && make
    cp ympd ~/.local/bin/
    cd $ipwd
fi
