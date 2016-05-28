#!/bin/bash
# create bootable image from running linux distro

#-------------------------------------------------
# Configure this as you require
#-------------------------------------------------
IMG_format=
IMG_name="debian8_jessie"
IMG_size=17

LNX_ver=`uname -r`
LNX_image="vmlinuz-$LNX_ver"
LNX_initrd="initrd.img-$LNX_ver"
LNX_rootdev="/dev/sda" #works on qemu and virtualbox
#-------------------------------------------------

TMPDIR="/mnt/vmd/"
WRKDIR="/media/domnic/tmp1"

create_img(){
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  echo "[I] image => $IMG"
  
  if [ -a "$IMG" ]; then
    echo "[W] [$IMG] already exists... skipped!"
  else
    echo "[I] creating filesystem ..."
    if [ "vdi" == "$IMG_format" ]; then
      #- create .vdi
      VBoxManage createhd --filename $IMG --size $(( IMG_size * 1024 ))
      modprobe nbd max_parts=16
      qemu-nbd -c /dev/nbd0 $IMG
      sleep 1
      parted -s /dev/nbd0 mklabel gpt 
      mkfs.ext4 /dev/nbd0
      sleep 1
      qemu-nbd -d /dev/nbd0
    else
      #- or create image on .raw disk
      qemu-img create -f raw $IMG ${IMG_size}G
      parted -s $IMG mklabel gpt 
      mkfs.ext4 -F $IMG
    fi
  fi
}

mount_img(){
  echo "[I] mount => $TMPDIR"
  IMG="$WRKDIR/$IMG_name.$IMG_format"
  if [ ! -d "$TMPDIR" ]; then
    mkdir -p $TMPDIR
  fi
  
  if [ "vdi" == "$IMG_format" ]; then
    #- mount .vdi
    #vdfuse -a -f $IMG /mnt/vdi
    #mount -o loop /mnt/vdi/Partition1 $TMPDIR
    modprobe nbd max_parts=16
    sleep 1
    qemu-nbd -c /dev/nbd0 $IMG
    sleep 1
    mount /dev/nbd0 $TMPDIR
  else
    #- mount image to tmpdir
    mount $IMG $TMPDIR
  fi
}

clone_img(){
  dryRun=1
  echo "[I] clone => $TMPDIR ($dryRun)"
  #- copy files
  if [ "1" == "$dryRun" ]; then
    time rsync -aAX \
      --info=progress2 \
      --delete \
      --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} \
      /* "$TMPDIR"
  fi

  #- install bootloader
  EXTDIR=$TMPDIR/boot/extlinux
  if [ -d $TMPDIR/boot/syslinux ]; then
    EXTDIR=$TMPDIR/boot/syslinux
  elif [ -d $TMPDIR/boot/extlinux ]; then
    EXTDIR=$TMPDIR/boot/extlinux
  else 
    mkdir -p $EXTDIR
  fi
  extlinux --install $EXTDIR 

  #- update bootloader
  #-- qemu default: root=/dev/sda
  cat > $TMPDIR/boot/syslinux/extlinux.conf <<- EOM
DEFAULT $IMG_name_$LNX_image
LABEL   $IMG_name_$LNX_image
SAY     Booting $IMG_name - $LNX_image
LINUX   /boot/$LNX_image
INITRD  /boot/$LNX_initrd
APPEND  root=$LNX_rootdev rw
EOM

  #-- remove invalid entries from $TMPDIR/etc/fstab
  cat > $TMPDIR/etc/fstab <<- EOM
/dev/sda   /   ext4   defaults   0   1 
EOM

  #-- let X detect video automatically
  mv /etc/X11/xorg.conf $TMPDIR/etc/X11/xorg.conf_disabled
}

unmount_img(){
  echo "[I] unmounting => $TMPDIR"
  #- unmount image and boot
  umount $TMPDIR
  if [ "vdi" == "$IMG_format" ]; then
    #umount /mnt/vdi
    qemu-nbd -d /dev/nbd0
  fi
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

validate_tool(){
  case $1 in
    vbox)
      if [ "x" == "x$(which VBoxManage)" ]; then
        echo "[I] VirtualBox::VBoxManage not installed, aborting!"
        exit -1;
      fi 
      ;;
    qemu)
      if [ "x" == "x$(which qemu-img)" ]; then
        echo "[I] Qemu::qemu-img, qemu-ndb not installed, aborting!"
        exit -1;
      fi 
      ;;
    parted)
      if [ "x" == "x$(which qemu-img)" ]; then
        echo "[I] Gnu::parted not installed, aborting!"
        exit -1;
      fi 
      ;;
    extlinux)
      if [ "x" == "x$(which extlinux)" ]; then
        echo "[I] Syslinux::syslinux, extlinux not installed, aborting!"
        exit -1;
      fi 
      ;;
  esac
}

# main
validate_tool "vbox"
validate_tool "qemu"
validate_tool "parted"
validate_tool "extlinux"

case $2 in
  vdi)
    IMG_format=$2
    ;;
  *)
    IMG_format=raw
    ;;
esac
case $1 in
  create_img)
    create_img
    ;;
  mount_img)
    mount_img
    ;;
  unmount_img)
    unmount_img
    ;;
  clone_img)
    clone_img
    ;;
  start_vm)
    start_vm
    ;;
  to_vdi)
    to_vdi
    ;;
  # compound  
  update_img)
    mount_img
    clone_img
    unmount_img
    ;;
  migrate)
    create_img
    mount_img
    clone_img
    unmount_img
    ;;
  resize_vdi)
    resize_vdi $2
    ;;
  *)
    echo "[?] unknown command."
    ;;
esac
