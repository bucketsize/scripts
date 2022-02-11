. ../common.sh

setup_prebuilt() {
    pkg=fseer.$(_arch).tar.gz
    cd /tmp
    wget https://github.com/bucketsize/fseer/releases/download/20220210/fseer.$(_arch).tar.gz 
    tar -xvzf $pkg -C ~/.local/bin
}

init_opam() {
    opam env
    if [ ! $? = 0 ]; then
        opam init
        eval $(opam env)
    fi
    if [ "$(which dune)" = "" ]; then
        opam install dune ounit2 ctypes ctypes-foreign stdio --yes
        eval $(opam env)
    fi
    eval $(opam env)
}

setup_sourcebuild() {
    cd ~/
    init_opam
    if [ ! -d ~/fseer ]; then
        git clone https://github.com/bucketsize/fseer.git
    fi
    cd ~/fseer
    git checkout master
    git pull
    ./build
    ./build pack fseer
    ./build install fseer
}

case $1 in
    source)
        setup_sourcebuild
        ;;
    prebuilt)
        setup_prebuilt
        ;;
    *)
        setup_sourcebuild
        ;;
esac

