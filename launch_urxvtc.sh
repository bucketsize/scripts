#!/bin/sh 

pgrep -laf urxvtd
if [ ! $? = 0 ]; then
    urxvtd -q -o -f
fi
urxvtc
