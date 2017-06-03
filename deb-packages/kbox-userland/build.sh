#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
build_env $1

rm -rf kbox-* *-tmp

#Pull source
URL="https://github.com/raspberrypi/firmware"
pull_source "${URL}" firmware

[ $RPI_MODEL = 1 ] && VERSION="$(ls firmware/modules | head -1)" || VERSION="$(ls firmware/modules | sort -r | head -1)"

if [ -d "firmware" ]; then

#  Build package kbox-userland
cp -r files files-tmp
cd files-tmp
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
[ $RPI_MODEL = 1 ]  && sed -i 's|hardfp/||g' debian/kbox-userland.install
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package kbox-userland-dev
cp -r files-dev files-dev-tmp
cd files-dev-tmp
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-userland (=${VERSION})" >> debian/control
echo "override_dh_shlibdeps:" >> debian/rules
[ $RPI_MODEL = 1 ]  && sed -i 's|hardfp/||g' debian/kbox-userland.install
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package kbox-userland-src
cp -r files-src files-src-tmp
cd files-src-tmp
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-userland (=${VERSION})" >> debian/control
echo "override_dh_shlibdeps:" >> debian/rules
[ $RPI_MODEL = 1 ]  && sed -i 's|hardfp/||g' debian/kbox-userland.install
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package kbox-bootloader
cp -r files-bootloader files-bootloader-tmp
cd files-bootloader-tmp
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv kbox-* ../packages

rm -rf *-tmp

else
 echo "Firmware folder not exist"
fi
popd
