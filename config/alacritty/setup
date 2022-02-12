#!/bin/sh
. ../common.sh

build_pack() {
    if [ -d ~/alacritty ]; then
        cd ~/alacritty
        git pull
    else
        githubfetch bucketsize/alacritty
        cd ~/alacritty
    fi
    if [ -f target/release/alacritty ]; then
        echo "existing build ..."
    else
        cargo build --release --no-default-features --features=x11
    fi
    tar -czf /tmp/alacritty.$(arch).tar.gz \
        target/release/alacritty \
        extra/logo/alacritty-term.svg \
        extra/linux/Alacritty.desktop
}

setup_prebuilt() {
    if [ -f ~/.local/bin/alacritty ]; then
        exit 0
    fi
    
    pkg-config alacritty
    if [ $? = 0 ]; then
        exit 0
    fi

    sudo apt install alacritty -y
    if [ $? = 0 ]; then
        exit 0 ;
    fi

    cd /tmp
    rm alacritty*gz*
    wget https://github.com/bucketsize/alacritty/releases/download/20220211/alacritty.aarch64.tar.gz
    [ $? = 0 ] || die "prebuilt not found, build from src: pack"
    tar -xvzf /tmp/alacritty.$(arch).tar.gz
    if [ "$(arch)" = "aarch64" ]; then
        mv /tmp/target/release/alacritty ~/.local/bin/_alacritty
        cat > ~/.local/bin/alacritty <<-EOF
#!/bin/sh
LIBGL_ALWAYS_SOFTWARE=1 ~/.local/bin/_alacritty
EOF
        chmod +x ~/.local/bin/alacritty
    else
        mv /tmp/target/release/alacritty ~/.local/bin/
    fi
}

setup_config() {
    updatelink $(pwd)/alacritty/my ~/.config/alacritty
}

case $1 in 
    pack)
        build_pack
        ;;
    *)
        setup_config
        setup_prebuilt
        ;;
esac

