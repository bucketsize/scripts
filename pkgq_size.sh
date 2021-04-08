#!/bin/sh
for i in $(cat /var/tmp/pkgq.log); do 
	echo $i
	
	n=$(echo $i | cut -f 2 -d "-")
	s=$(echo $i | cut -f 1 -d " ")
 	t=$(echo $i | cut -f 2 -d " ")
	#echo "$s $t"
	
	v=0
	if [ "$t" == "MiB" ]; then
		v=$(echo "$s * 1024" | bc)
	else
		v=s
	fi
	# echo "$v"
done
