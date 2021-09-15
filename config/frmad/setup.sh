checkpkgs "git libssl make pactl"

githubfetch bucketsize/minilib
githubfetch bucketsize/frmad

ipwd=$(pwd)
LIBDIR=/usr/lib/$(arch)-linux-gnu
cd ~/minilib && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR
cd ~/frmad && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR 
cd $ipwd