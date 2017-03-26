# (c) 2017 Cyr-ius
# email@ipocus.net

#!/bin/bash
export EMAIL="cyr-ius@ipocus.net"
export DEBFULLNAME="Cyr-ius Thozz"
export  KERNEL="${KERNEL_IMAGE}"
export KDEB_CHANGELOG_DIST="kodibox"
export KDEB_PKGVERSION="2"

# Fix Path for raspberry pi
mv "${KERNELSRC_DIR}/scripts/package/builddeb" "${KERNELSRC_DIR}/scripts/package/builddeb.old"
cp template-builddeb "${KERNELSRC_DIR}/scripts/package/builddeb"

# Clean the kernel sources
make -C "${KERNELSRC_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" mrproper

# Load default raspberry kernel configuration
make -C "${KERNELSRC_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" "${KERNEL_DEFCONFIG}"

# Cross compile kernel and modules
make deb-pkg -C "${KERNELSRC_DIR}" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" LOCALVERSION="-rpi${RPI_MODEL}" zImage modules dtbs

# Revert fix
mv "${KERNELSRC_DIR}/scripts/package/builddeb.old" "${KERNELSRC_DIR}/scripts/package/builddeb"
