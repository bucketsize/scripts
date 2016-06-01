#!/bin/bash 

validate(){
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
    sysbackup)
      if [ $# -lt 3 ]; then
        echo "No destination defined. Usage: $0 <cmd> <src> <dest>" >&2
        exit 1
      fi
      ;;      
    parted)
      pdev=$1
      if [ "/dev/sda" == $pdev ]; then
        echo "[E] not allowed [$pdev]"
        exit -1
      elif [ -b $pdev ]; then
        echo "[I] ok to part/format ... "
      else
        echo "[E] not a block device [$pdev]."
        exit -1
      fi
      ;;
  esac
}
