#!/bin/bash 

dpart(){
  pdev=$1
  validate_dev ${pdev}
  parted -s ${pdev} mklabel msdos
  parted -a optimal --script ${pdev} \
    unit MiB \
    mkpart primary ext4 0% 2% \
    mkpart extended 2% 100% \
    mkpart logical ext4 2% 100% \
    print \
    quit
}

validate_dev(){
  if [ "/dev/sda" == $pdev ]; then
    echo "[E] not allowed [$pdev]"
    exit -1
  fi
}

mkfs(){
  pdev=$1
  validate_dev ${pdev}    
  mkfs -t ext4 -F ${pdev}
}

case $1 in
  dpart)
    dpart $2
    ;;
  mkfs)
    mkfs $2
    ;;
  *)
    echo "[I] unknown action."
esac


