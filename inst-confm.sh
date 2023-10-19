#!/bin/sh

gh_get() {
	echo ">> getting [$1]"

	cd /var/tmp
	lf=$(basename $1)

	[ -f $lf.zip ] && rm -v $lf.zip
	curl -L https://codeload.github.com/$1/zip/refs/heads/main -o $lf.zip

	[ -d $lf-main ] && rm -rfv $lf-main
	unzip $lf.zip

	[ -d $lf ] && mv $lf $lf.1
	mv $lf-main $lf

}

gh_get bucketsize/scripts
gh_get bucketsize/conf-m
gh_get bucketsize/minilib
gh_get bucketsize/ictl
gh_get bucketsize/m360

echo "\nexport PATH=$PATH:$(pwd)/scripts" >>~/.profile
