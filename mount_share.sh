#!/bin/bash

host=$1
user=$2
pass=$3

echo "scanning $host for $user ..."

shares=`smbclient -L //$1 -U $user%$pass | grep Disk | cut -d " " -f 1`

echo "found shares:"
echo $shares

for i in $shares
do
    mkdir -p /mnt/smbfs_$host/$i
    cmd="mount -t cifs //$host/$i /mnt/smbfs_$host/$i -o username=$user,password=$pass"
    echo "issuing> $cmd"
    `$cmd`
done
