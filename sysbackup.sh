#!/bin/bash

backup(){
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
backup_progress(){
  RSYNC="ionice -c3 rsync"
  RSYNC_ARGS="-vrltD --delete --stats --human-readable"
  RSYNC_ARGS="$RSYNC_ARGS --exclude={\"/dev/*\",\"/proc/*\",\"/sys/*\",\"/tmp/*\",\"/run/*\",\"/mnt/*\",\"/media/*\",\"/lost+found\",\"/home/*\"}"
  SOURCES=$1
  TARGET=$2

  echo "Executing dry-run to see how many files must be transferred..."
  TODO=$(${RSYNC} --dry-run ${RSYNC_ARGS} ${SOURCES} ${TARGET}|grep "^Number of files transferred"|awk '{print $5}')

  ${RSYNC} ${RSYNC_ARGS} ${SOURCES} ${TARGET} | pv -l -e -p -s "$TODO"
}

if [ $# -lt 2 ]; then
  echo "No destination defined. Usage: $0 src destination" >&2
  exit 1
fi

START=$(date +%s)
echo "[I] backup ${1} => ${2}; ${START}"
time backup $1 $2
#backup_ex $1 $2
FINISH=$(date +%s)
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" | tee $2/"__BAK_$(date '+%Y-%m-%d_%T')"
