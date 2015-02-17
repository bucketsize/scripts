#!/bin/bash

echo "scanning $1 ..."

shares=`smbclient -L //$1 -U jb%foobar | grep Disk | cut -d " " -f 1`

echo "found shares:"
echo $shares

for i in $shares
do 
    echo "mounting //$1/$i -> /mnt/smbfs_$1/$i"
    mkdir -p /mnt/smbfs_$1/$i
    mount -t cifs //$1/$i /mnt/smbfs_$1/$i
done
