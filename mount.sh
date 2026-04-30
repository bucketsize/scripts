#!/usr/bin/env bash
# Generate fstab entries for unmounted block devices with optimized options
# Default: user-writable and exec allowed

LSBLK_JSON=$(lsblk -J -o NAME,MOUNTPOINT,FSTYPE,UUID,LABEL)

echo "# Optimized fstab entries (user-writable, exec, high throughput)"
echo "# <file system> <mount point> <type> <options> <dump> <pass>"

echo "$LSBLK_JSON" | jq -r '
  .blockdevices[]
  | recurse(.children[]?)
  | select(.mountpoint == null and .uuid != null)
  | (.fstype // "auto") as $fs
  | (
      if $fs == "ext4" then "defaults,noatime,nodiratime,discard,commit=60,errors=remount-ro"
      elif $fs == "xfs" then "defaults,noatime,nodiratime,discard,allocsize=1M,inode64"
      elif $fs == "btrfs" then "defaults,noatime,ssd,space_cache,autodefrag,compress=zstd"
      else "defaults"
      end
    ) as $opts
  | "UUID=" + .uuid
    + "  /mnt/" + (.name)
    + "  " + $fs
    + "  " + $opts + ",rw,user,exec"
    + "  0  2"
'


