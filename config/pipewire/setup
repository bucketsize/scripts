#!/bin/sh
. ../common.sh

checkpkgs "pipewire"

sessf=/etc/pipewire/media-session.d/with-pulseaudio
servd=/etc/systemd/user

if [ ! -f $sessf ] ; then
    echo "installing pulse session [with-pulseaudio] ..."
    sudo touch $sessf
fi

if [ "$(ls $servd/pipewire-pulse.*)" = "" ]; then
    echo "installing pulse service ..."
    sudo cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* $servd/
fi

systemctl --user daemon-reload
systemctl --user --now enable pipewire pipewire-pulse
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user mask pulseaudio
