#!/bin/bash

. ../../functions.sh
rm -rf kbox-*.deb  "$(pwd)/../../packages/kbox-*.deb"

version="1.0.1"

# Set version
fix_version files/DEBIAN/control $version

#  Build package
dpkg_build files/ kbox-splashscreen-$version.deb

# Create packages repositorie
mkdir -p "$(pwd)/../../packages"

# Move packages
mv -f kbox-*.deb "$(pwd)/../../packages"
