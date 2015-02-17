#!/bin/bash
#
# Start a composition manager.
# (xcompmgr in this case)

comphelp() {
  echo "Composition Manager:"
  echo "   (re)start: COMP"
  echo "   stop:      COMP -s"
  echo "   query:     COMP -q"
  echo "              returns 0 if composition manager is running, else 1"
  exit
}

checkcomp() {
  pgrep xcompmgr &>/dev/null
}

stopcomp() {
  checkcomp && killall xcompmgr
}

startcomp() {
  stopcomp
  xcompmgr -CcfF -I-.015 -O-.03 -D2 -t-1 -l-3 -r4.2 -o.5 &
  exit
}

case "$1" in
  "")   startcomp ;;
  "-q") checkcomp ;;
  "-s") stopcomp; exit ;;
  *)    comphelp ;;
esac
