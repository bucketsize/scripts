. ../common.sh

setup_prebuilt() {
    pkg=fseer.$(arch).tar.gz
    cd /tmp
    wget https://www.dropbox.com/s/l0f1t59eit2muf4/$pkg
    tar -xvzf $pkg -C ~/.local/bin
}

init_opam() {
    opam env
    if [ ! $? = 0 ]; then
        opam init
        eval $(opam env)
    fi
    if [ "$(which dune)" = "" ]; then
        opam install dune ounit2 ctypes ctypes-foreign stdio
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
setup_sourcebuild

