#!/bin/bash
# create bootable image from running linux distro

#-------------------------------------------------
# Configure this as you require
#-------------------------------------------------
IMG_format=
IMG_name="t_debian8_jessie"
IMG_size=17

LNX_ver=`uname -r`
LNX_image="vmlinuz-$LNX_ver"
LNX_initrd="initrd.img-$LNX_ver"
LNX_rootdev="/dev/sda" #works on qemu and virtualbox
#-------------------------------------------------

TMPDIR="/mnt/vmd21/"
WRKDIR="/media/domnic/tmp1"

source ./sysbackup.sh 
source ./create_parts.sh 
source ./validations.sh 

create_img(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] create => $IMG"

  if [ -a "$IMG" ]; then
    echo "[W] [$IMG] already exists... skipped!"
  else
    if [ "vdi" == "$IMG_format" ]; then
      VBoxManage createhd --filename $IMG --size $(( IMG_size * 1024 ))
    else
      qemu-img create -f raw $IMG ${IMG_size}G
    fi
  fi
}
prepare_img_pre(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] preparing => $IMG"

  if [ "vdi" == "$IMG_format" ]; then
    modprobe nbd max_parts=16
    qemu-nbd -c /dev/nbd0 $IMG
    sleep 1
    dpart /dev/nbd0
    sleep 1
    qemu-nbd -d /dev/nbd0
  else
    losetup /dev/loop0 $IMG
    sleep 1
    dpart /dev/loop0      
    sleep 1
    losetup -d /dev/loop0
  fi
}
prepare_img_post(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] preparing post_part => $IMG"
  if [ "vdi" == "$IMG_format" ]; then
    modprobe nbd max_parts=16
    qemu-nbd -c /dev/nbd0 $IMG
    dformat /dev/nbd0
  else
    losetup /dev/loop0 $IMG
    sleep 1
    dformat /dev/loop0
  fi
}
prepare_img_post2(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] preparing post_part => $IMG"
  if [ "vdi" == "$IMG_format" ]; then
    modprobe nbd max_parts=16
    qemu-nbd -c /dev/nbd0 $IMG
  else
    losetup /dev/loop0 $IMG
  fi
}
cleanup_img_post(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  if [ "vdi" == "$IMG_format" ]; then
    qemu-nbd -d /dev/nbd0
  else
    losetup -d /dev/loop0
  fi
}
mount_img(){
  echo "[I] mount => $TMPDIR"
  boot=
  root=
  if [ "vdi" == "$IMG_format" ]; then
    boot=/dev/nbd0p1
    root=/dev/nbd0p5
  else
    boot=/dev/loop0p1
    root=/dev/loop0p5
  fi
  disk_mount $root $boot $TMPDIR
}
umount_img(){
  echo "[I] umount => $TMPDIR"
  boot=
  root=
  if [ "vdi" == "$IMG_format" ]; then
    boot=/dev/nbd0p1
    root=/dev/nbd0p5
  else
    boot=/dev/loop0p1
    root=/dev/loop0p5
  fi
  disk_umount $root $boot
}
clone_img(){
  echo "[I] clone => $TMPDIR ($dryRun)"
  #rsync_cmd / $TMPDIR

  boot=
  root=
  if [ "vdi" == "$IMG_format" ]; then
    boot=/dev/nbd0p1
    root=/dev/nbd0p5
  else
    boot=/dev/loop0p1
    root=/dev/loop0p5
  fi
  extlinux_install `uname -r` /dev/loop0 /dev/sda5 /dev/sda1 $TMPDIR  
}

start_vm(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] vm => $IMG"

  qemu-system-i386 \
    -display sdl \
    -soundhw ac97 \
    -vga cirrus \
    $IMG
}

to_vdi(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  IMG_vdi="$WRKDIR/$IMG_name.vdi"
  echo "[I] converting $IMG => $IMG_vdi"

  if [ -f $IMG_vdi ]; then
    echo "[W] already exists: $IMG_vdi"
    rm $IMG_vdi
  fi
  echo "[I] vm => $IMG => $IMG_vdi"

  #VBoxManage convertfromraw --format VDI [filename].img [filename].vdi
  time VBoxManage convertfromraw --format VDI $IMG $IMG_vdi
}

resize_vdi(){
  RESIZE=$1
  IMG_vdi="$WRKDIR/$IMG_name.vdi"
  echo "[I] resizing => $IMG_vdi => $RESIZE"

  #VBoxManage modifyhd <absolute path to file> --resize <size in MB>
  VBoxManage modifyhd $IMG_vdi --resize $RESIZE

  #TODO mount and resize fs
}

# main

set -e

validate "vbox"
validate "qemu"
validate "parted"
validate "extlinux"

case $2 in
  vdi)
    IMG_format=$2
    ;;
  *)
    IMG_format=raw
    ;;
esac
case $1 in
  start_vm)
    start_vm
    ;;
  to_vdi)
    to_vdi
    ;;
  update)
    prepare_img_post
    mount_img
    clone_img
    umount_img
    cleanup_img_post
    ;;
  migrate)
    create_img
    prepare_img_pre
    prepare_img_post
    mount_img
    clone_img
    umount_img
    cleanup_img_post
    ;;
  resize_vdi)
    resize_vdi $2
    ;;
  *)
    echo "[?] unknown command."
    ;;
esac
