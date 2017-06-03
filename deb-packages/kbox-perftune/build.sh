#!/bin/bash
VERSION="1.1"

pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf kbox-* *-tmp

#  Build package
cp -r files files-tmp
cd files-tmp
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv kbox-* ../packages

rm -rf *-tmp
popd
