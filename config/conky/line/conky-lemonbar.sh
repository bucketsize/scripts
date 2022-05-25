#!/bin/sh

# Now send blocks with information forever:
conky -c $HOME/cfg/conky/line/conky-lemonbar.conf \
	| lemonbar -f "cozette"\
	| sh
