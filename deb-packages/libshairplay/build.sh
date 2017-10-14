#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

VERSION="0.9.0"
CURRENT_PATH=$(pwd)
export PATH=${CURRENT_PATH}/../../tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:$PATH

rm -rf libshairplay* *-tmp

URL="https://github.com/juhovh/shairplay.git"
pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
./autogen.sh
./configure --host=$CROSS_COMPILE PREFIX=/usr
make -j4
cd ..

cp -r files files-bin-tmp
cp -r files-dev files-dev-tmp

make install -C files-tmp DESTDIR=$(pwd)/files-bin-tmp VERBOSE=1
make install -C files-tmp DESTDIR=$(pwd)/files-dev-tmp VERBOSE=1

cd files-bin-tmp
echo "override_dh_usrlocal:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version $VERSION
fix_distribution "stretch"
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

cd files-dev-tmp
echo "override_dh_usrlocal:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version $VERSION
fix_distribution "stretch"
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../../packages
mv libshairplay* ../../packages

rm -rf *-tmp
popd
