#!/bin/bash
pushd $(dirname "$0")
. ./../../functions.sh

URL="https://github.com/raspberrypi/firmware"

#Clean folder
rm -rf kbox-* *-tmp

#Pull source
pull_source "${URL}" firmware

version="$(ls firmware/modules | sort -r | head -1)"

if [ -d "firmware" ]; then

#  Build package
cp -r files files-tmp
cd files-tmp
sed "s/(1.0)/($version)/g" -i debian/changelog
dpkg-buildpackage -us -uc
cd ..

cp -r files-dev files-dev-tmp
cd files-dev-tmp
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-userland (=${version})" >> debian/control
sed "s/(1.0)/($version)/g" -i debian/changelog
dpkg-buildpackage -us -uc
cd ..

cp -r files-src files-src-tmp
cd files-src-tmp
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-userland (=${version})" >> debian/control
sed "s/(1.0)/($version)/g" -i debian/changelog
dpkg-buildpackage -us -uc
cd ..

cp -r files-bootloader files-bootloader-tmp
cd files-bootloader-tmp
sed "s/(1.0)/($version)/g" -i debian/changelog
dpkg-buildpackage -us -uc
cd ..

rm -rf *-tmp

else
 echo "Firmware folder not exist"
fi
popd
