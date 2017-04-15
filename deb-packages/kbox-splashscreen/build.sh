#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

version="1.0.2"
rm -rf kbox-* *-tmp

#  Build package
cp -r files files-tmp
cd files-tmp
sed "s/(1.0)/($version)/g" -i debian/changelog
dpkg-buildpackage -us -uc
cd ..
rm -rf *-tmp
popd
