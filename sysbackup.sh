#!/bin/bash

source ./validations.sh 

dpart(){
  pdev=$1
  echo "[I] creating partitions on [$pdev] for fresh isntall" 
  validate parted ${pdev}
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

  ls -l ${pdev}p1
  ls -l ${pdev}p5

  validate parted $pdev
  mkfs -t ext2 -F ${pdev}p1
  mkfs -t ext4 -F ${pdev}p5
}

rsync1_cmd(){
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
rsync2_cmd(){
  RSYNC="ionice -c3 rsync"
  RSYNC_ARGS="-vrltD --delete --stats --human-readable"
  RSYNC_ARGS="$RSYNC_ARGS --exclude={\"/dev/*\",\"/proc/*\",\"/sys/*\",\"/tmp/*\",\"/run/*\",\"/mnt/*\",\"/media/*\",\"/lost+found\",\"/home/*\"}"
  SOURCES=$1
  TARGET=$2

  echo "Executing dry-run to see how many files must be transferred..."
  TODO=$(${RSYNC} --dry-run ${RSYNC_ARGS} ${SOURCES} ${TARGET}|grep "^Number of files transferred"|awk '{print $5}')

  ${RSYNC} ${RSYNC_ARGS} ${SOURCES} ${TARGET} | pv -l -e -p -s "$TODO"
}
fresh_install(){
  backup=$1
  blockDev=$2
  source ./create_parts.sh 
  dpart ${blockDev}

  #guess created partitions
  for i in `ls ${blockDev}*`; do
    echo "$i"
  done
}
disk_mount(){
  root=$1
  boot=$2
  tmpd=$3

  mkdir -p $tmpd
  mount $root $tmpd

  if [ "x" != "x$boot" ]; then
    mkdir -p $tmpd/boot
    mount $boot $tmpd/boot
  fi
}
disk_umount(){
  root=$1
  boot=$2
  tmpd=$3

  umount $boot 
  umount $root
}
part_install(){
  backup=$1
  rootDev=$2
  bootDev=$3 #optional

  echo "[I] installing ${backup} => boot:${bootDev} => root:${rootDev}"

  rsync1_cmd $backup /mnt/tmp_root

  install_extlinux `uname -r` ${rootDev} ${bootDev} /mnt/tmp_root
}
grub_install(){
  LNX_ver=$1
  LNX_hdd=$2
  LNX_rootdev=$3
  LNX_bootdev=$4 #TODO include in fstab
  LNX_boot_hdd=/dev/sda #asuming this is the first disk
  LTMPDIR=$5

  LNX_image=vmlinuz-$LNX_ver
  LNX_initrd=initrd.img-$LNX_ver

  cat > $LTMPDIR/boot/grub/grub.cfg <<-EOM
set default="0"
set timeout="3"
insmod msdospart
insmod ext2
set root='($LNX_boot_hdd, msdos1)'
search --no-floppy
menuentry "$LNX_image" {
  linux $LNX_image root=$LNX_boot_hdd rw
  initrd $LNX_initrd
}
EOM
  cat $LTMPDIR/boot/grub/grub.cfg
  
  echo "installing grub => $LNX_bootdev => $LTMPDIR/boot => $LNX_hdd"
  grub-install --boot-directory=$LTMPDIR/boot $LNX_hdd
}
extlinux_install(){
  LNX_ver=$1
  LNX_hdd=$2
  LNX_rootdev=$3
  LNX_bootdev=$4 #TODO include in fstab
  LNX_boot_hdd=/dev/sda #asuming this is the first disk
  LTMPDIR=$5

  LNX_image=vmlinuz-$LNX_ver
  LNX_initrd=initrd.img-$LNX_ver

  #- install bootloader
  EXTDIR=$LTMPDIR/boot/extlinux
  if [ -d $LTMPDIR/boot/syslinux ]; then
    EXTDIR=$LTMPDIR/boot/syslinux
  elif [ -d $LTMPDIR/boot/extlinux ]; then
    EXTDIR=$LTMPDIR/boot/extlinux
  else 
    mkdir -p $EXTDIR
  fi
  echo "[I] extlinux =>  $LNX_hdd -> $EXTDIR"
  #- update bootloader config
  #-- qemu default: root=/dev/sda
  cat > $EXTDIR/extlinux.conf <<- EOM
  DEFAULT $LNX_image
  LABEL   $LNX_image
  SAY     Booting - $LNX_image
  LINUX   /boot/$LNX_image
  INITRD  /boot/$LNX_initrd
  APPEND  root=$LNX_boot_hdd rw
EOM
  cat $EXTDIR/extlinux.conf

  extlinux --install $EXTDIR 

  MBR_bin=
  for i in `find /usr/lib -name mbr.bin`; do 
    #take the first one
    MBR_bin=$i
    break;
  done
  echo "[I] extlinux = $MBR_bin"
  dd if=${MBR_bin} conv=notrunc bs=440 count=1 of=${LNX_hdd}
}

cleanup_oldconfigs(){
  LTMPDIR=$1
  #-- remove invalid entries from $TMPDIR/etc/fstab
  cat > $LTMPDIR/etc/fstab <<- EOM
  $LNX_rootdev   /   ext4   defaults   0   1 
EOM
  cat $LTMPDIR/etc/fstab 

  #-- let X detect video automatically
  mv /etc/X11/xorg.conf $LTMPDIR/etc/X11/xorg.conf_disabled

  #-- existing user min restore
  mkdir $LTMPDIR/home/jb 
  chown jb.jb -R $LTMPDIR/home/jb
}
