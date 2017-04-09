#!/bin/bash

rm -rf linux-*  "$(pwd)/../../kernel-packages"
export EMAIL="cyr-ius@ipocus.net"
export DEBFULLNAME="Cyr-ius Thozz"
export KDEB_CHANGELOG_DIST="kernel"

# Clean the kernel sources
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" mrproper

# Load default raspberry kernel configuration
make -C "linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" "${KERNEL_DEFCONFIG}"

# Cross compile kernel and modules
make deb-pkg -C "linux" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" zImage modules dtbs && echo "Make and package successful" || echo "Kernel make failed"

# Create metapackage
version=`cat "linux/include/config/kernel.release"`
rev=$(cat linux/.version)
revision=$(($rev-1))
pkgversion=$version-$revision
fix_version files/DEBIAN/control $pkgversion
sed '/Depends/d' -i files/DEBIAN/control
echo "Depends: kbox-bootloader (=${version}), kbox-userland (=${version}), linux-firmware-image-${version} (=${pkgversion}), linux-image-${version} (=${pkgversion}), linux-libc-dev (=${pkgversion})" >> files/DEBIAN/control
dpkg_build files/ kbox-linux-$pkgversion.deb

# Create packages repositorie
mkdir -p "$(pwd)/../../packages"

# Move packages
mv -f kbox-linux-$pkgversion.deb "$(pwd)/../../packages"

# Create kernel packages repositorie
mkdir -p "$(pwd)/../../kernel-packages"

# Move packages
mv -f linux-* "$(pwd)/../../kernel-packages"
