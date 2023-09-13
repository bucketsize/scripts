#!/bin/bash
# create bootable image from running linux distro

#-------------------------------------------------
# Configure this as you require
#-------------------------------------------------
IMG_format=
IMG_name="jb_11235"
IMG_size=24

LNX_ver=$(uname -r)
LNX_image="vmlinuz-$LNX_ver"
LNX_initrd="initrd.img-$LNX_ver"
LNX_rootdev="/dev/sda" #works on qemu and virtualbox
#-------------------------------------------------

TMPDIR="/mnt/vmd21/"
dryRun=false

#WRKDIR="/media/domnic/tmp1"
WRKDIR="/media/jb/83460770-be50-4a0f-bee1-113eac851f93/mnt/deb_bak-fuh_home/"

cleanup_nbd() {
	if [ -a /dev/nbd0 ]; then
		qemu-nbd -d /dev/nbd0
		rmmod nbd
	fi
	modprobe nbd max_part=16
}
create_target() {
	IMG="$WRKDIR/$IMG_name.$IMG_format"
	echo "#create_img $IMG"
	if [ -a "$IMG" ]; then
		echo "[W] [$IMG] already exists... skipped!"
	else
		qemu-img create -f raw $IMG ${IMG_size}G
	fi

	echo "#mount_img $IMG"
	losetup -d /dev/loop0
	sleep 1
	losetup /dev/loop0 $IMG
	sleep 1
}

prepare_target() {
	dev=$1
	echo "#prepare_target $dev"
	partition $dev
	sleep 1

	echo "#format_img $IMG"
	format $dev
	sleep 1
}

mount_target() {
	tmpdir=$1
	boot=$2
	root=$3
	echo "#mount_fs -> $tmpdir"
	disk_mount $root $boot $tmpdir
}

umount_target() {
	tmpdir=$1
	boot=$2
	root=$3
	echo "#mount_fs -> $tmpdir"
	disk_umount $root $boot
}

copy_files() {
	tmpdir=$1
	rsync_cmd / $tmpdir
}

install_bootloader() {
	tmpdir=$1
	boot=$2
	root=$3
	grub_install $(uname -r) $hdd /dev/sda5 /dev/sda1 /dev/sda $TMPDIR
}
start_vm() {
	IMG="$WRKDIR/$IMG_name.$IMG_format"
	echo "[I] vm => $IMG"

	qemu-system-x86 \
		-display sdl \
		-soundhw ac97 \
		-vga cirrus \
		$IMG
}

set -e
