#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

VERSION="1.0.5"

[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
build_env $1

rm -rf arm-mem* *-tmp
[ "$1" = "3_64" ] && echo "INFO : Package not necessary, bye bye" && exit 0

#  Build package kbox-userland
cp -r files files-tmp
pushd src
make clean
CROSS_COMPILE="${CROSS_COMPILE}-" make
cp libarmmem.so libarmmem.a ../files-tmp
popd

cd files-tmp
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv arm-mem* ../packages

rm -rf arm-mem* *-tmp
popd
