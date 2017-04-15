#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh
URL="https://github.com/juhovh/shairplay.git"
rm -rf raspi-config* *-tmp

pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
./configure
make
dpkg-buildpackage -us -uc
cd ..
rm -rf *-tmp
popd
