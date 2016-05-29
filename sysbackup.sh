#!/bin/bash

rsync_cmd(){
  # -a archive
  # -A preserve acls
  # -X preserve extended attributes
  # -v verbosity
  # --delete extraneous files from destination
  # don't use --progress
  ionice -c3 rsync \
    -aAX \
    --delete \
    --info=progress2 \
    --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} \
    "$1" "$2"
}
rsync_cmd2(){
  RSYNC="ionice -c3 rsync"
  RSYNC_ARGS="-vrltD --delete --stats --human-readable"
  RSYNC_ARGS="$RSYNC_ARGS --exclude={\"/dev/*\",\"/proc/*\",\"/sys/*\",\"/tmp/*\",\"/run/*\",\"/mnt/*\",\"/media/*\",\"/lost+found\",\"/home/*\"}"
  SOURCES=$1
  TARGET=$2

  echo "Executing dry-run to see how many files must be transferred..."
  TODO=$(${RSYNC} --dry-run ${RSYNC_ARGS} ${SOURCES} ${TARGET}|grep "^Number of files transferred"|awk '{print $5}')

  ${RSYNC} ${RSYNC_ARGS} ${SOURCES} ${TARGET} | pv -l -e -p -s "$TODO"
}

install_fresh(){
  backup=$1
  rootDev=$2
  bootDev=$3 #optional
  
  echo "[I] installing ${backup} => boot:${bootDev} => root:${rootDev}"
  mkdir -p /mnt/tmp_root
  mount $rootDev /mnt/tmp_root

  if [ "x" != "x$bootDev" ]; then
    mkdir -p /mnt/tmp_root/boot
    mount $bootDev /mnt/tmp_root/boot
  fi
 
  rsync_cmd $backup /mnt/tmp_root

  install_extlinux `uname -r` ${rootDev} ${bootDev} /mnt/tmp_root
}

install_extlinux(){
  LNX_ver=$1
  LNX_hdd=$2
  LNX_rootdev=$3
  LNX_bootdev=$4 #TODO include in fstab
  LTMPDIR=$5
  
  LNX_image=vmlinux-$LNX_ver
  LNX_initrd=initrd.img-$LNX_ver

  #-- remove invalid entries from $TMPDIR/etc/fstab
  cat > $LTMPDIR/etc/fstab <<- EOM
$LNX_rootdev   /   ext4   defaults   0   1 
EOM
  cat $LTMPDIR/etc/fstab 
  
  #-- let X detect video automatically
  mv /etc/X11/xorg.conf $LTMPDIR/etc/X11/xorg.conf_disabled

  #- update bootloader config
  #-- qemu default: root=/dev/sda
  cat > $EXTDIR/extlinux.conf <<- EOM
DEFAULT $LNX_image
LABEL   $LNX_image
SAY     Booting - $LNX_image
LINUX   /boot/$LNX_image
INITRD  /boot/$LNX_initrd
APPEND  root=$LNX_rootdev rw
EOM
  cat $EXTDIR/extlinux.conf

  #- install bootloader
  EXTDIR=$LTMPDIR/boot/extlinux
  if [ -d $LTMPDIR/boot/syslinux ]; then
    EXTDIR=$LTMPDIR/boot/syslinux
  elif [ -d $LTMPDIR/boot/extlinux ]; then
    EXTDIR=$LTMPDIR/boot/extlinux
  else 
    mkdir -p $EXTDIR
  fi
  extlinux --install $EXTDIR 

  MBR_bin=
  for $i in `find /usr/lib -name mbr.bin`; do 
    #take the first one
    MBR_bin=$i
    break;
  done
  dd if=${MBR_bin} conv=notrunc bs=440 count=1 of=${LNX_hdd}

}

validate(){
  if [ $# -lt 3 ]; then
    echo "No destination defined. Usage: $0 <cmd> <src> <dest>" >&2
    exit 1
  fi
}

echo "[I] ${1} ${2} => ${3}"
case $1 in 
  install)
    install_fresh $2 $3 $4 $5
    ;;
  backup)
    rsyn_cmd $2 $3
    ;;
  *)
    echo "[E] unknown command."
    ;;
esac
