#!/bin/bash

LNX_ver=3.10.0-327.el7.x86_64
LNX_dev=/dev/sdb
LNX_boot_hdd=/dev/sda #assuming this is the first disk
LTMPDIR=/mnt/ltmpdir

LNX_rootdev=${LNX_dev}5
LNX_bootdev=${LNX_dev}1 #TODO include in fstab


dpart(){
  pdev=$1
  echo "[I] creating partitions on [$pdev] for fresh isntall" 
  parted -s ${pdev} mklabel msdos
  parted -a optimal --script ${pdev} \
    unit MiB \
    mkpart primary ext2 0% 2% \
    mkpart extended 2% 100% \
    mkpart logical ext4 2% 100% \
    set 1 boot on \
    print \
    quit
}
dformat(){
  echo "[I] formatting partitions on [$pdev] for fresh isntall" 
  pdev=$1

  ls -l ${pdev}1
  ls -l ${pdev}5

  mkfs -t ext2 -F ${pdev}1
  mkfs -t ext4 -F ${pdev}5
}
install_extlinux(){
  LNX_image=vmlinuz-$LNX_ver
  LNX_initrd=initramfs-${LNX_ver}.img
  EXTDIR=$LTMPDIR/boot/extlinux

  #- install bootloader
  mkdir -p $EXTDIR
  echo "[I] extlinux =>  $LNX_dev -> $EXTDIR"
  
  #- update bootloader config
  #-- qemu default: root=/dev/sda
  cat > $EXTDIR/extlinux.conf <<- EOM 
  DEFAULT menu.c32
  PROMPT 1
  LABEL   $LNX_image
  SAY     Booting - $LNX_image 123
  LINUX   /$LNX_image
  INITRD  /$LNX_initrd
  APPEND  root=${LNX_boot_hdd}5 ro rhgb quiet LANG=en_IN.UTF-8
EOM
  cat $EXTDIR/extlinux.conf

  extlinux --install $EXTDIR 

  MBR_bin=/usr/share/syslinux/mbr.bin 
  echo "[I] extlinux = $MBR_bin"
  dd if=${MBR_bin} conv=notrunc bs=440 count=1 of=${LNX_dev}

  cp /usr/share/syslinux/menu.c32 $EXTDIR 
}

sync(){
  rsync \
    -aAX \
    --delete \
    --exclude={"/boot/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} \
    "/" "${LTMPDIR}"
}
mparts(){
  pdev=$1
  echo "[I] mounting partitions of [$pdev] on ${LTMPDIR}"

  mkdir -p ${LTMPDIR}
  mount ${pdev}5 ${LTMPDIR}
  
  if [ -d ${LTMPDIR}/boot ]; then
    echo "[I] boot/ found in root/"
  else
    # mainly for testing 
    mkdir ${LTMPDIR}/boot
    echo "[W] boot/ not found in root/"
  fi

  mount ${pdev}1 ${LTMPDIR}/boot
}
umparts(){
  pdev=$1
  echo "[I] unmounting partitions of [$pdev] on ${LTMPDIR}"

  umount ${pdev}1 
  umount ${pdev}5 
}
update_conf(){
  echo "updating fstab"
  cp conf/_fstab ${LTMPDIR}/etc/fstab 
}

#dpart "${LNX_dev}" && sleep 1
#dformat "${LNX_dev}" && sleep 1
mparts "${LNX_dev}" && sleep 1
sync && sleep 1
install_extlinux && sleep 1
update_conf && sleep 1
umparts "${LNX_dev}" && sleep 1

