#!/bin/sh

svr_inst=/home/jb/.local/share/Steam/steamapps/common/SteamVR
svr_dest=/mnt/f1aa/data/SteamLibrary/steamapps/common/SteamVR
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/lib/

sudo dnf install git python311 ImageMagick glew \
	ffmpeg xwd xwininfo \
	xdg-user-dirs xdg-desktop-portal-gnome qt5-qtbase qt5-qtmultimedia \
	make gcc cmake clang \
	mesa-libGL-devel mesa-libGLU-devel mesa-libGLw-devel \
	glew-devel qt5-qtbase-devel

sudo apt install --no-install-recommends \
	git python3.11 imagemagick glew-utils \
	ffmpeg x11-utils x11-apps \
	xdg-user-dirs xdg-desktop-portal-gtk qtbase5-dev qtmultimedia5 libqt5opengl5 \
	make gcc cmake clang \
	libgl1-mesa-dev libglu1-mesa-dev libglw1-mesa-dev \
	libglew-dev

sudo ln -s /usr/sbin/getcap /usr/bin/getcap
sudo ln -s /usr/sbin/setcap /usr/bin/setcap

mkdir ~/ws
cd ~/ws

# openvr steam sdk
#git clone https://github.com/ValveSoftware/openvr.git
#git checkout v1.26.7
wget https://github.com/ValveSoftware/openvr/archive/refs/tags/v1.26.7.tar.gz
tar -xvzf v1.26.7.tar.gz

cd openvr-1.26.7/

# lib
cmake -DBUILD_SHARED=1 \
	-DCMAKE_INSTALL_PREFIX=$HOME/.local/ \
	-DCMAKE_BUILD_TYPE=Release \
	-DUSE_SYSTEM_JSONCPP=True \
	.
make
make install

# samples (optional)
cd samples
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local/ -Wno-dev .
make
make install DESTDIR="$pkgdir"

if [ "$install_examples" = true ]; then
	# Install examples
	install -d "$pkgdir/usr/bin"
	install -d "$pkgdir/usr/shaders"

	cd samples

	#TODO: fix openvr upstream source to look in proper place for resources
	install -m 755 "bin/linux64/hellovr_vulkan" "$pkgdir/usr/bin"
	for shader in "bin/shaders/"*.spv; do
		install -m 755 "$shader" "$pkgdir/usr/shaders"
	done

	install -m 755 "bin/linux64/hellovr_opengl" "$pkgdir/usr/bin"
	install -m 755 "bin/hellovr_actions.json" "$pkgdir/usr/"
	install -m 755 "bin/linux64/helloworldoverlay" "$pkgdir/usr/bin"
	install -m 755 "bin/linux64/tracked_camera_openvr_sample" "$pkgdir/usr/bin"
	install -m 755 "bin/cube_texture.png" "$pkgdir/usr/"
fi

# trinus
git clone --depth 1 https://github.com/MyrikLD/LinusTrinus
cd LinusTrinus
/usr/bin/python3.11 -m venv .venv
. .venv/bin/activate
pip3 install wand frame-generator evdev

# drivers
(
	cd samples/
	./make.sh
	cd ..
)

python3 main.py &

# steam
mkdir -p $HOME/.steam/steam/common/SteamVR
mount --bind $svr_inst $svr_dest
steam &
