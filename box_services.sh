or(){
    if [ "$1" != "" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}
require(){
    if [ "" == "$(which $1)" ]; then 
        echo "? $1"
    fi
}
launch(){
    echo "launch $1"
    $1 2>$HOME/.cache/$1.err 1>$HOME/.cache/$1.out & 
}
init_start() {
    require 'xrandr'
    require 'xset'
    require 'xrdb'
    
    xrandr --output default --mode 1368x768 --pos 0x0 --rotate normal
    xset -b 
    xrdb -merge $HOME/scripts/conf/Xresources
    [ ! -d $HOME/.cache ] &&  mkdir -p $HOME/.cache
}
compositer_start() {
    require 'compton'
    compton -CcfF -I-.05 -O-.07 -D2 -t-1 -l-3 -r4.2 -o.5
}
compositer_stop(){
    killall compton
}
wallpaper_start() {   
    require 'wget' 
    require 'feh' 
    require 'xmllint' 

    WALLPAPERS="$HOME/.cache/wallpapers"

    [ ! -d $WALLPAPERS ] &&  mkdir -p $WALLPAPERS

    rndn=$(od -A n -t d -N 1 /dev/urandom)
    idx=$((1 + rndn % 2000))
    url="https://www.bing.com/HPImageArchive.aspx?format=xml&idx=$idx&n=1"

    ipath=$(curl -s "$url" | xmllint --xpath "//image/url/text()" -)
    iname=$(echo $ipath | sed "s/\//\./g")
    wname="$WALLPAPERS/$iname"

    wget "http://www.bing.com/$ipath" -O "$wname" &&
        exec feh --bg-scale "$wname"

    if [ "$" != "0" ]; then
        wname=$(find "$WALLPAPERS/" -type f | shuf | head -n 1) && exec feh --bg-scale "$wname"
    fi
}
panel_start() {
    require 'tint2'
    tint2 -c $(or $1 $HOME/scripts/conf/tint2rc)
}
panel_stop(){
    killall tint2
}
notifier_start() {
    require 'dunst' 
    dunst -config $(or $1 $HOME/scripts/conf/dunstrc)
}
notifier_stop(){
    killall dunst
}
monitor_start() {
    require 'conky' 
    conky --config $(or $1 $HOME/scripts/conf/conkyrc_vline)
}
monitor_stop(){
    killall conky
}
netapp_start() {
    require 'nm-applet' 
    nm-applet
}
netapp_stop(){
    killall nm-applet
}
clipboard_start() {
    require 'clipit' 
    clipit
}
clipboard_stop(){
    killall clipit
}
volapp_start() {
    require 'volumeicon' 
    volumeicon
}
volapp_stop(){
    killall volumeicon
}
screenlocker_start() {
    require 'xautolock' 
    require 'i3lock' 
    require 'convert' 
    xautolock -time 15 -locker "scripts/i3lock-fancy" -notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking screen in 30 seconds'"
}
screenlocker_stop(){
    killall xautolock
}
shortcuts_start(){
    require 'dmenu' 
    require 'scrot' 
    require 'xkill'
    require 'amixer'
    require 'sxhkd'
    sxhkd -c $HOME/scripts/conf/sxhkdrc
}
shortcuts_stop(){
    killall sxhkd
}
polkit_start(){
    require '/usr/lib/xfce4/xfce-polkit'
    /usr/lib/xfce4/xfce-polkit
}
polkit_stop(){
    killall xfce-polkit
}
gsudo(){
    require 'pkexec'

    echo "gsudo $1 > $DISPLAY, $XAUTHORITY"
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $1
}
logout(){
    require 'openbox'

    #TODO: start using dbus / lightdm
    case $XDG_SESSION_DESKTOP in
        openbox)
            openbox --exit
            ;;
        *)
            echo "don't know how to logout"
    esac
}
handle_power(){
    require 'zenity'
    require 'pm-suspend'
    require 'pm-hibernate'

    popt=$(zenity --width=200 --height=100 --list --column "F" --title="choice" "Logout" "Suspend" "Hibernate" "Reboot" "PowerOff" --hide-header --modal)

    # terminal look
    # poptf=/tmp/.poptf
   # st -g 40x20 -e dialog --no-shadow --no-ok --no-cancel --clear --colors --backtitle "Power" --title "Options" --menu "" 10 30 3 Suspend "" Poweroff "" Hibernate "" 2> $poptf
    # popt=$(cat $poptf)

    case $popt in
        Logout)
            gsudo logout 
            ;;

        # start using dbus, upowerd    
        Suspend)
            gsudo pm-suspend
            ;;
        Hibernate)
            gsudo pm-hibernate
            ;;
        Reboot)
            gsudo reboot 
            ;;
        Poweroff)
            gsudo poweroff
            ;;
    esac
}

