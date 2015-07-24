#!/bin/bash

if [ $# -lt 2 ]; then
    echo "No destination defined. Usage: $0 src destination" >&2
    exit 1
elif [ $# -gt 2 ]; then
    echo "Too many arguments. Usage: $0 src destination" >&2
    exit 1
elif [ ! -d "$2" ]; then
   echo "Invalid path: $2" >&2
   exit 1
elif [ ! -w "$2" ]; then
   echo "Directory not writable: $2" >&2
   exit 1
fi

case "$2" in
  "/mnt") ;;
  "/mnt/"*) ;;
  "/media") ;;
  "/media/"*) ;;
  "/run/media") ;;
  "/run/media/"*) ;;
  *) echo "Destination not allowed." >&2
     exit 1
     ;;
esac

START=$(date +%s)

echo "going to backup ${1} -> ${2} at ${START}"

# -a archive
# -A preserve acls
# -X preserve extended attributes
# -v verbosity
# --delete extraneous files from destination
rsync -aAX --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} "$1" "$2"


# rdiff-backup
#CMD="rdiff-backup \
#	--include-filelist exclude_list \
#	/ $1"
#echo "issing: $CMD"
#$CMD

FINISH=$(date +%s)

echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" | tee $2/"__BAK_$(date '+%Y-%m-%d_%T')"
