#!/bin/bash
# run from <streamlibrary/steamapps>

appid=$1
target=$2
installdir=$(grep -Po "(?<=installdir\")".* appmanifest_$appid.acf | xargs)
[ -d $target/$appid ] || mkdir -pv "$target/$appid/common" \
	mkdir -pv "$target/$appid/compdata" \
	mkdir -pv "$target/$appid/shadercache"
cp -av appmanifest_$appid.acf $target/$appid/
cp -av "common/$installdir/" $target/$appid/common/
cp -av "compdata/$appid/" $target/$appid/compdata/
cp -av "shadercache/$appid/" $target/$appid/shadercache/
