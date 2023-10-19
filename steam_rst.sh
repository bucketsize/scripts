#!/bin/bash
# run from "<backup/appid> dir containing appmanifest_appid.acf"

CP="cp -av"
CP="echo"

appid=$1
target=$2 #steam libarary root folder
installdir=$(grep -Po "(?<=installdir\")".* appmanifest_$appid.acf | xargs)
$CP appmanifest_$appid.acf $target/steamapps/
$CP "common/$installdir/" $target/steamapps/common/
$CP "compdata/$appid/" $target/steamapps/compdata/
$CP "shadercache/$appid/" $target/steamapps/shadercache/
