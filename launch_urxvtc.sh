#!/bin/sh 

pgrep -laf urxvtd
if [ ! $? = 0 ]; then
    nohup urxvtd -q -o -f > /dev/null &
fi
nohup urxvtc > /dev/null &
