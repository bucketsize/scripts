#!/bin/sh

[ -d my/plugged ] ||\
	([ -f my/plug.tgz ] && tar -xzf my/plug.tgz -C my)

ln -s ~/scripts/config/nvim/my ~/.config/nvim



