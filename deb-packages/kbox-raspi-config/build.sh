#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf raspi-config* *-tmp

#Pull source
URL="https://github.com/RPi-Distro/raspi-config.git"
pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
sed -i "s/jessie;/stable;/g" debian/changelog
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv raspi-config* ../packages

rm -rf *-tmp
popd
