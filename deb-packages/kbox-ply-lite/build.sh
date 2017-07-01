#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

VERSION="1.1"

[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
build_env $1

rm -rf ply-lite* *-tmp

#  Build package kbox-userland
cp -r files files-tmp
pushd src
make clean
CROSS="${CROSS_COMPILE}" CROSS_COMPILE="${CROSS_COMPILE}-" make
cp ply-image checkmodifier splash_early splash.png splash_sad.png ../files-tmp
make clean
popd
cd files-tmp
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv ply-lite* ../packages

rm -rf ply-lite* *-tmp
popd
