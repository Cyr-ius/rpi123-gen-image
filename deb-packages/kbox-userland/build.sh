#!/bin/bash

rm -rf kbox-*.deb  "$(pwd)/../../packages/kbox-*.deb"

version="$(ls firmware/modules | sort -r | head -1)"

fix_version files/DEBIAN/control $version
fix_version files-dev/DEBIAN/control $version
fix_version files-src/DEBIAN/control $version
fix_version files-bootloader/DEBIAN/control $version

sed '/Depends/d' -i files-dev/DEBIAN/control
echo "Depends: kbox-userland (=${version})" >> files-dev/DEBIAN/control
sed '/Depends/d' -i files-src/DEBIAN/control
echo "Depends: kbox-userland (=${version})" >> files-src/DEBIAN/control

if [ -d "firmware" ]; then
mkdir -p files/opt/vc
mkdir -p files-dev/opt/vc
mkdir -p files-src/opt/vc
mkdir -p files-bootloader/boot
cp -ar firmware/hardfp/opt/vc/bin/ files/opt/vc
cp -ar firmware/hardfp/opt/vc/lib files/opt/vc
cp -ar firmware/hardfp/opt/vc/include files-dev/opt/vc
cp -ar firmware/hardfp/opt/vc/src files-src/opt/vc

cp firmware/boot/bootcode.bin files-bootloader/boot
cp firmware/boot/fixup.dat files-bootloader/boot
cp firmware/boot/fixup_cd.dat files-bootloader/boot
cp firmware/boot/fixup_x.dat files-bootloader/boot
cp firmware/boot/start.elf files-bootloader/boot
cp firmware/boot/start_cd.elf files-bootloader/boot
cp firmware/boot/start_x.elf files-bootloader/boot

dpkg_build files/ kbox-userland-$version.deb
dpkg_build files-dev/ kbox-userland-dev-$version.deb
dpkg_build files-src/ kbox-userland-src-$version.deb
dpkg_build files-bootloader/ kbox-bootloader-$version.deb

# Create packages repositorie
mkdir -p "$(pwd)/../../packages"

# Move packages
mv -f kbox-*.deb "$(pwd)/../../packages"

rm -rf files/opt files-dev/opt files-src/opt files-bootloader/boot

else
 echo "Firmware folder not exist"
fi
