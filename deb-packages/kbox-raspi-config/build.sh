#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh
URL="https://github.com/asb/raspi-config.git"
rm -rf raspi-config* *-tmp

pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
sed -i "s/unstable/stable/g" debian/changelog
dpkg-buildpackage -us -uc
cd ..
rm -rf *-tmp
popd
