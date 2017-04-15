#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh
URL="https://github.com/Pulse-Eight/platform.git"
rm -rf *p8-platform* *-tmp

pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
cp debian/changelog.in debian/changelog
sed -i "s/#DIST#/stable/g" debian/changelog
sed -i "s|\*/||g" debian/*.install
echo "override_dh_shlibdeps:" >> debian/rules
cmake -DCMAKE_C_COMPILER="arm-linux-gnueabihf-gcc" -DCMAKE_CXX_COMPILER="arm-linux-gnueabihf-g++" -DCMAKE_STRIP="/usr/bin/arm-linux-gnueabihf-strip"  .
make
DEB_BUILD_OPTIONS=nostrip dpkg-buildpackage -d -us -uc -a armhf
cd ..
rm -rf *-tmp
popd
