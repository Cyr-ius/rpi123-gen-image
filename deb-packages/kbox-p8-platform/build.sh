#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf *p8-platform* *-tmp

#Pull source
URL="https://github.com/Pulse-Eight/platform.git"
pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
cp debian/changelog.in debian/changelog
sed -i "s/#DIST#/stable/g" debian/changelog
sed -i "s|\*/||g" debian/*.install
echo "override_dh_shlibdeps:" >> debian/rules
cmake -DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" -DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip"  .
make
DEB_BUILD_OPTIONS=nostrip dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv *p8-platform* ../packages

rm -rf *-tmp
popd
