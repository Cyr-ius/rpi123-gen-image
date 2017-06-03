#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf kbox-* linux-*  *-tmp

#Pull source
RESET="true"
URL="https://github.com/raspberrypi/linux"
pull_source "${URL}" "linux"

export EMAIL="cyr-ius@ipocus.net"
export DEBFULLNAME="Cyr-ius Thozz"
export KDEB_CHANGELOG_DIST="kernel"
export KBUILD_DEBARCH=$RELEASE_ARCH

KERNEL_THREADS=$(grep -c processor /proc/cpuinfo)

# Clean the kernel sources
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" mrproper

# Load default raspberry kernel configuration
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" "${KERNEL_DEFCONFIG}"

# Cross compile kernel and modules
make deb-pkg -C "linux" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" zImage modules dtbs && echo "Make and package successful" || echo "Kernel make failed"

# Create metapackage
version=`cat "linux/include/config/kernel.release"`
revision=$(cat linux/.version)
VERSION=$version-$revision

cp -r files files-tmp
cd files-tmp
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-bootloader (=${version}), kbox-userland (=${version}), linux-firmware-image-${version} (=${VERSION}), linux-image-${version} (=${VERSION}), linux-libc-dev (=${VERSION})" >> debian/control
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv kbox-* linux-* ../packages

rm -rf *-tmp
popd
