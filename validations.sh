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
  esac
}
