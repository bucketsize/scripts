#!/bin/bash 

dpart(){
  pdev=$1
  echo "[I] creating partitions on [$pdev] for fresh isntall" 
  validate_dev ${pdev}
  parted -s ${pdev} mklabel msdos
  parted -a optimal --script ${pdev} \
    unit MiB \
    mkpart primary ext2 0% 2% \
    mkpart extended 2% 100% \
    mkpart logical ext4 2% 100% \
    print \
    quit
}
dformat(){
  echo "[I] formatting partitions on [$pdev] for fresh isntall" 
  pdev=$1

  ls -l ${pdev}p1
  ls -l ${pdev}p5

  validate_dev $pdev
  mkfs -t ext2 -F ${pdev}p1
  mkfs -t ext4 -F ${pdev}p5
}

validate_dev(){
  if [ "/dev/sda" == $pdev ]; then
    echo "[E] not allowed [$pdev]"
    exit -1
  elif [ -b $pdev ]; then
    echo "[I] ok to part/format ... "
  else
    echo "[E] not a block device [$pdev]."
    exit -1
  fi
}

case $1 in
  dpart)
    dpart $2
    ;;
  *)
    echo "[I] unknown action."
esac


