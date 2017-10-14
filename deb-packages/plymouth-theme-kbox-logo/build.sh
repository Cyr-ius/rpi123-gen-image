#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (0 | 1 | 2 | 3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

VERSION="1.0.6"

rm -rf plymouth-* *-tmp

# Pull source
URL="https://github.com/cyr-ius/plymouth-theme-kbox-logo"
pull_source "${URL}" "files-tmp"

#  Build package
pushd files-tmp
fix_version $VERSION
fix_distribution "stretch"
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH 
popd

mkdir -p ../../packages
mv plymouth-* ../../packages

rm -rf *-tmp
popd
