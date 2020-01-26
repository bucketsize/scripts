or(){
    if [ "$1" != "" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}
require(){
    if [ -z "$(which $1)" ]; then
        echo "? $1"
    fi
}
launch(){
    if [ ! -d ~/.cache ]; then
        mkdir ~/.cache
    fi
    cmd=$*
    echo "cmd> $cmd"
    $cmd 2>$HOME/.cache/xlaunch.err 1>$HOME/.cache/xlaunch.out &
}
gsudo(){
    require 'pkexec'
    echo "gsudo $1 > $DISPLAY, $XAUTHORITY"
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $1
}
xrun(){
    require 'dmenu_run'
    dmenu_run
}

