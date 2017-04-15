#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

RPI_MODEL=2
URL="https://github.com/raspberrypi/linux"
RESET="true"

rm -rf linux-* kbox-linux* *-tmp

pull_source "${URL}" "linux"

export EMAIL="cyr-ius@ipocus.net"
export DEBFULLNAME="Cyr-ius Thozz"
export KDEB_CHANGELOG_DIST="kernel"

CROSS_COMPILE="arm-linux-gnueabihf-"
KERNEL_ARCH="arm"
KERNEL_THREADS=4
KERNEL_DEFCONFIG=`[ ${RPI_MODEL} = 1 ] && echo bcmrpi_defconfig || echo bcm2709_defconfig`
KERNEL_IMAGE=`[ ${RPI_MODEL} = 1 ] && echo kernel.img || echo kernel7.img`


# Clean the kernel sources
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" mrproper

# Load default raspberry kernel configuration
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" "${KERNEL_DEFCONFIG}"

# Cross compile kernel and modules
make deb-pkg -C "linux" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" zImage modules dtbs && echo "Make and package successful" || echo "Kernel make failed"

# Create metapackage
version=`cat "linux/include/config/kernel.release"`
revision=$(cat linux/.version)
pkgversion=$version-$revision
cp -r files files-tmp
cd files-tmp
sed "s/(1.0)/($pkgversion)/g" -i debian/changelog
sed '/Depends/d' -i debian/control
echo "Depends: \${misc:Depends}, kbox-bootloader (=${version}), kbox-userland (=${version}), linux-firmware-image-${version} (=${pkgversion}), linux-image-${version} (=${pkgversion}), linux-libc-dev (=${pkgversion})" >> debian/control
dpkg-buildpackage -us -uc -a armhf
cd ..
rm -rf *-tmp
popd
