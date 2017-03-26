# (c) 2017 Cyr-ius
# email@ipocus.net

#!/bin/bash
export EMAIL="cyr-ius@ipocus.net"
export DEBFULLNAME="Cyr-ius Thozz"
export  KERNEL="${KERNEL_IMAGE}"
export KDEB_CHANGELOG_DIST="kodibox"
export KDEB_PKGVERSION="2"

# Fix Path for raspberry pi
sed "s|installed_image_path=\"boot/vmlinuz-\$version\"|installed_image_path=\"boot/${KERNEL_IMAGE}\"|g" -i "${KERNELSRC_DIR}/scripts/package/builddeb"


if [ ! $(grep -s "arch/\$ARCH/boot/dts/\*\.dtb" "${KERNELSRC_DIR}/scripts/package/builddeb") ]; then
	sed -i '/INSTALL_DTBS_PATH/a \
		cp arch/$ARCH/boot/dts/*.dtb "$tmpdir/boot" \
		cp arch/$ARCH/boot/dts/overlays/*.dts "$tmpdir/boot/overlays" \
	' "${KERNELSRC_DIR}/scripts/package/builddeb"
fi

# Clean the kernel sources
make -C "${KERNELSRC_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" mrproper

# Load default raspberry kernel configuration
make -C "${KERNELSRC_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" "${KERNEL_DEFCONFIG}"

# Cross compile kernel and modules
make deb-pkg -C "${KERNELSRC_DIR}" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" LOCALVERSION="-rpi${RPI_MODEL}" zImage modules dtbs
