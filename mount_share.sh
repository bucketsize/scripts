#!/bin/bash

mount_share(){
  host=$1
  user=$2
  pass=$3

  echo "scanning ${host} for ${user} ..."
  shares=`smbclient -L //${host} -U ${user}%${pass} | grep Disk | cut -d " " -f 1`
  echo "found shares:"
  echo $shares

  for i in $shares
  do
    ss=//${host}/${i}
    mp=/mnt/smbfs_${host}/${i} 
    mkdir -p ${mp}
    cmd="mount -t cifs ${ss} ${mp} -o username=${user},password=${pass}"
    echo "issuing> $cmd"
    `$cmd`
  done
}

mount_share $1 $2 $3
