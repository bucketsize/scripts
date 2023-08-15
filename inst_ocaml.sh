#!/bin/sh

. ./common.sh
checkpkgs "opam"

opam env
if [ $? != 0 ]; then
    opam init
    opam env
else
    echo "already installed: ocaml"
fi

eval $(opam env)
