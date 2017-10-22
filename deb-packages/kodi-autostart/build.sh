#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

rm -rf kodi-autostart* *-tmp

# Pull source
URL="https://github.com/cyr-ius/kodi-autostart"
pull_source "${URL}" "files-tmp"

#  Build package
pushd files-tmp
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
popd

mkdir -p ../../packages
mv kodi-autostart*  ../../packages

rm -rf *-tmp
popd
