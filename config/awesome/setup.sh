#!/bin/sh

cd copycats/
cat ../my/copycats.diff | git apply
ln -s ../my/rc.lua ./
ln -s ../my/awesome-switcher/ ./
