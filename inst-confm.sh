#!/bin/sh

rm -rf /var/tmp/smmf/
mkdir /var/tmp/smmf/
cd /var/tmp/smmf/
wget https://codeload.github.com/bucketsize/minilib/zip/refs/heads/main -O mi.zip
wget https://codeload.github.com/bucketsize/mxctl/zip/refs/heads/main -O mx.zip
wget https://codeload.github.com/bucketsize/frmad/zip/refs/heads/main -O fr.zip
wget https://codeload.github.com/bucketsize/conf-m/zip/refs/heads/main -O co.zip
wget https://codeload.github.com/bucketsize/scripts/zip/refs/heads/master -O sc.zip

unzip mi.zip
unzip mx.zip
unzip fr.zip
unzip co.zip
unzip sc.zip

cd minilib-main
luarocks make --local
cd ..
cd mxctl-main
luarocks make --local
cd ..
cd frmad-main
luarocks make --local
cd ..

[ -d ~/conf-m/ ] || mv conf-m-main ~/conf-m/
[ -d ~/scripts/ ] || mv scripts-master ~/scripts/
