#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

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
make install DESTDIR=${CURRENT_PATH}/files-tmp/debian/tmp
echo "override_dh_shlibdeps:" >> debian/rules
sed "s/Architecture: all/Architecture: $RELEASE_ARCH/g" -i debian/control
dpkg-buildpackage -b -nc -us -uc -a $RELEASE_ARCH

cd ..

mkdir -p ../../packages
mv libshairplay* ../../packages

rm -rf *-tmp
popd
