#!/bin/bash

#-d display 			 Specifies the display to manage.
#-r radius			 Specifies the blur radius for client-side shadows.
#-o opacity			 Specifies the opacity for client-side shadows.
#-l left-offset			 Specifies the left offset for client-side shadows.
#-t top-offset			 Specifies the top offset for client-side shadows.
#-I fade-in-step			 Specifies the opacity change between steps while fading in.
#-O fade-out-step			 Specifies the opacity change between steps while fading out.
#-D fade-delta       Specifies the time (in milliseconds) between steps in a fade.

#-a     Automatic server-side compositing.  This instructs the server to use the standard composition rules.  Useful for debugging.
#-c     Client-side compositing with soft shadows and translucency support.
#-f     When -c is specified, enables a smooth fade effect for transient windows like menus, and for all windows on hide and restore events.
#-n     Simple client-side compositing.
#-s     Server-side compositing with hard-edged shadows.
#-C     When -c is specified, attempts to avoid painting shadows on panels and docks.
#-F     When -f is specified, also enables the fade effect when windows change their opacity, as with transset(1).
#-S     Enables synchronous operation.  Useful for debugging.

COMP=compton
#OPTS="-CcfF -I-.05 -O-.07 -D2 -t-1 -l-3 -r4.2 -o.5"
checkcomp() {
  pgrep $COMP &>/dev/null
}
stopcomp() {
  checkcomp && killall $COMP
}
startcomp() {
  stopcomp
  $COMP $OPTS &
  exit
}
case $1 in
    status)
        checkcomp ;;
    stop)
        stopcomp ;;
    start)
        startcomp ;;
esac
