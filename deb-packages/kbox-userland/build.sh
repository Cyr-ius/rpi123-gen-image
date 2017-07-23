#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found, please add raspberrypi model ( 0 | 1 | 2 | 3 | 3x64 )" && exit
build_env $1

rm -rf rpi* *-tmp

[ "$RPI_MODEL" = "1" ] || [ "$RPI_MODEL" = "0" ] && RPI_TYPE="1"
[ "$RPI_MODEL" = "2" ] || [ "$RPI_MODEL" = "3" ] && RPI_TYPE="2"
[ "$RPI_MODEL" = "3x64" ] && RPI_TYPE="3"

RESET=true

#Pull source
URL="https://github.com/raspberrypi/linux"
pull_source "${URL}" "linux"

if [ -d "linux" ]; then

   export EMAIL="cyr-ius@ipocus.net"
   export DEBFULLNAME="Cyr-ius Thozz"
   export KDEB_CHANGELOG_DIST="kernel"
   #~ export KDEB_PKGVERSION=$(make -C ./linux kernelversion | grep -v make)-1
   export KBUILD_DEBARCH=$RELEASE_ARCH

   KERNEL_THREADS=$(grep -c processor /proc/cpuinfo)

   # Clean the kernel sources
   make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" mrproper

   # Load default raspberry kernel configuration
   make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" "${KERNEL_DEFCONFIG}"

   [ "$RPI_MODEL" = "3x64" ] && KERNEL_IMAGE=Image.gz || KERNEL_IMAGE=zImage
   
   # Cross compile kernel and modules
   #~ #make -C "linux" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" ${KERNEL_IMAGE} modules dtbs && echo "Make and package successful" || echo "Kernel make failed"
   make deb-pkg -C "linux" -j$KERNEL_THREADS ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" ${KERNEL_IMAGE} modules dtbs && echo "Make and package successful" || echo "Warning while make kernel"

   # Create metapackage
   release=`cat "linux/include/config/kernel.release"`
   revision=$(cat linux/.version)
   version=$release-$revision

   cp -r files-firmware files-firmware-tmp
   cd files-firmware-tmp
   sed "s/rpi-firmware/rpi$RPI_TYPE-firmware/g" -i debian/changelog
   sed "s/rpi-firmware/rpi$RPI_TYPE-firmware/g" -i debian/control
   sed '/Depends/d' -i debian/control
   echo "Depends: \${misc:Depends}, rpi-bootloader-${release} (=${version}), rpi-userland-${release} (=${version}), linux-firmware-image-${release} (=${version}), linux-image-${release} (=${version}), linux-libc-dev (>=${version})" >> debian/control
   fix_version_changelog $version
   fix_arch $RELEASE_ARCH
   dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
   cd ..
fi

#Pull source
URL="https://github.com/raspberrypi/firmware"
pull_source "${URL}" "firmware"

if [ -d "firmware" ]; then

#  Build package rpi-userland
cp -r files files-tmp
cd files-tmp
sed "s/rpi-userland/rpi-userland-${release}/g" -i debian/changelog
sed "s/rpi-userland/rpi-userland-${release}/g" -i debian/control
echo "override_dh_strip:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $version
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package rpi-userland-dev
cp -r files-dev files-dev-tmp
cd files-dev-tmp
sed "s/rpi-userland-dev/rpi-userland-dev-${release}/g" -i debian/changelog
sed "s/rpi-userland-dev/rpi-userland-dev-${release}/g" -i debian/control
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, rpi-userland-${release} (=${version})" >> debian/control
echo "override_dh_strip:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $version
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package rpi-userland-src
cp -r files-src files-src-tmp
cd files-src-tmp
sed "s/rpi-userland-src/rpi-userland-src-${release}/g" -i debian/changelog
sed "s/rpi-userland-src/rpi-userland-src-${release}/g" -i debian/control
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, rpi-userland-${release} (=${version})" >> debian/control
echo "override_dh_strip:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $version
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

#  Build package rpi-bootloader
cp -r files-bootloader files-bootloader-tmp
cd files-bootloader-tmp
sed "s/rpi-bootloader/rpi-bootloader-${release}/g" -i debian/changelog
sed "s/rpi-bootloader/rpi-bootloader-${release}/g" -i debian/control
echo "override_dh_strip:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $version
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv rpi* linux-* ../packages

rm -rf *-tmp

else
 echo "Firmware folder not exist"
fi
popd
