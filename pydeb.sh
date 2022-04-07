wget https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
tar xvf Python-3.6.9.tgz
cd Python-3.6.9
./configure --enable-optimizations --enable-shared
make -j8

export DEBEMAIL="bucket.size@gmail.com"
export DEBFULLNAME="Jaya Balan Aaron"

dh_make --createorig -p python-3.6.9
dh_auto_configure
dpkg-buildpackage -rfakeroot -us -uc -b

