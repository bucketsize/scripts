export DEBEMAIL="bucket.size@gmail.com"
export DEBFULLNAME="Jaya Balan Aaron"

wayland=wayland-1.20.0
wayland_proto=wayland-protocols-1.25
weston=weston-10.0.0

c=$(pwd)

for p in $wayland_proto $weston; do
	echo "\n## making >> ${p}"
	if [ ! -d /tmp/${p} ]; then
		tar -xf ${p}.tar.xz -C /tmp
	fi
	cd /tmp/${p}
	dh_make --createorig -p ${p}
	dh_auto_configure --buildsystem=meson 
	dpkg-buildpackage -rfakeroot -us -uc -b
	cd ${c}
done
