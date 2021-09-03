#!/bin/sh

[ -d my/plugged ] || tar -xzf my/plug.tgz -C my
ln -s ~/scripts/config/nvim/my ~/.config/nvim


