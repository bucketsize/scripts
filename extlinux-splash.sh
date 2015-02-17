#!/bin/bash
size="640x480"
convert -resize 640x480 -depth 16 -colors 256 $1 $1.splash.png
