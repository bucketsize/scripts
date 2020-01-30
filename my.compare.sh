#!/bin/bash

for i in `ls $1`; do 
	[ -d $2/$i ] && echo "$i: $(find $1/$i -type f | wc -l) - $(find $2/$i -type f | wc -l)"
done
