#!/bin/bash

sensors | grep -Po '(?<=\+)(.*)(?=\.*°C\s+\()' | while read -r line; do 
if [ "$line" > "40.0" ] ; then	
echo $line
fi
done
