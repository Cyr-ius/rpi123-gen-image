#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

VERSION="0.9.0"
CURRENT_PATH=$(pwd)
export PATH=${CURRENT_PATH}/../../tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:$PATH

rm -rf libshairplay* *-tmp

# Pull source
URL="https://github.com/cyr-ius/shairplay.git"
pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
./autogen.sh
./configure --host=$CROSS_COMPILE PREFIX=/usr
make -j4
make install DESTDIR=${CURRENT_PATH}/files-tmp/debian/tmp VERBOSE=1
echo "override_dh_usrlocal:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
echo "override_dh_autoreconf:" >> debian/rules
echo "override_dh_auto_configure:" >> debian/rules
fix_version $VERSION
fix_distribution "stretch"
sed "s/Architecture: all/Architecture: $RELEASE_ARCH/g" -i debian/control
dpkg-buildpackage -b -nc -us -uc -a $RELEASE_ARCH

cd ..

#~ cp -r files files-bin-tmp

#~ make install -C files-tmp DESTDIR=$(pwd)/files-bin-tmp VERBOSE=1

#~ cd files-bin-tmp
#~ echo "override_dh_usrlocal:" >> debian/rules
#~ echo "override_dh_shlibdeps:" >> debian/rules
#~ fix_version $VERSION
#~ fix_distribution "stretch"
#~ sed "s/Architecture: all/Architecture: $RELEASE_ARCH/g" -i debian/control
#~ dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
#~ cd ..


mkdir -p ../../packages
mv libshairplay* ../../packages

rm -rf *-tmp
popd
