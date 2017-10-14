#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (0 | 1 | 2 | 3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

VERSION="1.0.6"

rm -rf plymouth-* *-tmp

#  Build package
cp -r files files-tmp
cd files-tmp
fix_version $VERSION
fix_distribution "stretch"
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH 
cd ..

mkdir -p ../../packages
mv plymouth-* ../../packages

rm -rf *-tmp
popd
