. ../common.sh

pkg=fseer.$(arch).tar.gz
cd /tmp
wget https://www.dropbox.com/s/l0f1t59eit2muf4/$pkg
tar -xvzf $pkg -C ~/.local/bin
