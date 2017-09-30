#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (0 | 1 | 2 | 3)" && exit
build_env $1

rm -rf kbox-* *-tmp

VERSION="1.0.5"

#  Build package
cp -r files files-tmp
cd files-tmp
fix_version_changelog $VERSION
echo $VERSION $RELEASE_ARCH
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH 
cd ..

mkdir -p ../packages
mv kbox-* ../packages

rm -rf *-tmp
popd
