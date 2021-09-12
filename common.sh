die() {
    echo "$1"
    exit 1
}
or(){
    if [ "$1" != "" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}
require(){
    if [ -z "$(which $1)" ]; then
        die "missing '$1'"
    fi
}
gsudo(){
    require 'pkexec'
    echo "gsudo $1 > $DISPLAY, $XAUTHORITY"
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $1
}
rndstr(){
    echo $(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
}
rs=$(rndstr)
createdir(){
    dst=$1
    [ -d $dst ] || mkdir -p $dst
}
checkpkgs() {
    status=0
    a=$1
    for i in $a; do
        pkg-config $i 
        if [ "$?" != "0" ]; then
            which $i > /dev/null
            if [ "$?" != "0" ]; then
                echo "pkg [$i] not installed"
                status=1
            fi
        fi
    done
    if [ "$status" != "0" ]; then
        die ".. aborting!"
    fi
}
requirefiles(){
    status=0
    a=$1
    for i in $a; do
        if [ ! -f "$i" ]; then
            echo "require file [$i]"
            status=1
        fi
    done
    if [ "$status" != "0" ]; then
        die ".. aborting!"
    fi
}
updatelink() {
    src=$1
    dst=$2
    [ -d $src ] || [ -f $src ] || die "config for $src not found" 
    if ([ -d $dst ] || [ -f $dst ]) && [ ! -L $dst ]; then
        mv $dst $dst.$rs
    fi
    if [ -L $dst ]; then
        rm $dst
    fi
    ln -s $src $dst
}
githubfetch() {
    b=$(echo "$1" | cut -d"/" -f1)
    r=$(echo "$1" | cut -d"/" -f2)
    [ -d ~/$r ] || git clone https://github.com/$b/$r.git ~/$r
		ipwd=$(pwd)
		cd ~/$r
		git pull
		cd $ipwd
}
