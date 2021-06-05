#!/bin/sh

colors=($(xrdb -query | sed -n 's/.*color\([0-9]\)/\1/p' | sort -nu | cut -f2))

echo -e "\e[1;37m
 Black      Red        Green      Yellow     Blue       Magenta    Cyan       White
───────────────────────────────────────────────────────────────────────────────────────\e[0m"
for i in {0..7}; do echo -e "\e[$((30+$i))m █ ${colors[i]} \e[0m :: color$i"; done
echo
for i in {8..15}; do echo -e "\e[1;$((22+$i))m █ ${colors[i]} \e[0m :: color$i"; done
echo -e "\n"
