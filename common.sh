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
    [ -f $dst ] && mv $dst $dst.$rs
    [ -d $dst ] || mkdir -p $dst
}
checkpkgs() {
    for i in $1; do
        pkg-config $i 
        if [ ! $? = 0 ]; then
            which $i > /dev/null
            if [ ! $? = 0 ]; then
                echo "pkg [$i] required"
                exit 10
            fi
        fi
    done
}
requirefiles(){
    for i in $1; do
        if [ ! -f $i ]; then
            echo "file [$i] required"
            exit 10
        fi
    done
}
updatelink() {
    src=$1
    dst=$2
    [ -d $src ] || [ -f $src ] || die "config for $src not found" 
    if [ -d $dst ] || [ -f $dst ] || [ -L $dst ]; then
        echo "moving [$dst]"
        mv $dst $dst.$rs
    fi
    if [ ! -d $(dirname $dst) ]; then
        echo "mkdir [$(dirname $dst)]"
        mkdir -p $(dirname $dst)
    fi
    cmd="ln -s $src $dst"
    echo "> $cmd"
    $cmd
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
_arch(){
    arch=$(grep -o -w 'lm' /proc/cpuinfo | sort -u)
    if [ "$arch" = "lm" ];then echo "x86_64"
    fi
}
