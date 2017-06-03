#
# Build and Setup RPi2/3 Kernel
#

# Load utility functions
. ./functions.sh

# Prepare boot (firmware) directory
mkdir -p "${BOOT_DIR}"

#Fake kernel
touch "${BOOT_DIR}/${KERNEL_IMAGE}"

# Add hooks for kernel install packages
mkdir -p "${ETC_DIR}/kernel/postinst.d"
mkdir -p "${ETC_DIR}/kernel/preinst.d"
install_exec files/etc/kernel/postinst.d/process-vmlinuz "${ETC_DIR}/kernel/postinst.d"
install_exec files/etc/kernel/postinst.d/update-config "${ETC_DIR}/kernel/postinst.d"
install_exec files/etc/kernel/preinst.d/preprocess-vmlinuz "${ETC_DIR}/kernel/preinst.d"
install_readonly files/etc/kernel-img.conf "${ETC_DIR}"

# Install Kernel package if exists
if [ ! -z "$APT_INCLUDES_KERNEL" ] ; then
{
  install_deb $APT_INCLUDES_KERNEL
  if [ ! $? ]; then
	echo "error: kernel not found"
	cleanup
	exit 1
  fi
  return;
} fi

# Fetch and build latest raspberry kernel
if [ "$BUILD_KERNEL" = true ] ; then
{
	# Setup source directory
	mkdir -p "${R}/usr/src"

	# Copy existing kernel sources into chroot directory
	if [ -n "$KERNELSRC_DIR" ] && [ -d "$KERNELSRC_DIR" ] ; then
	{
	    # Copy kernel sources
	    cp -r "${KERNELSRC_DIR}" "${R}/usr/src/linux"

	    # Clean the kernel sources
	    if [ "$KERNELSRC_CLEAN" = true ] && [ "$KERNELSRC_PREBUILT" = false ] ; then
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" mrproper
	    fi
	}
	else
	{
		    # Create temporary directory for kernel sources
		    temp_dir=$(sudo -u nobody mktemp -d)

		    # Fetch current RPi2/3 kernel sources
		    sudo -u nobody git -C "${temp_dir}" clone --depth=1 "${KERNEL_URL}"

		    # Copy downloaded kernel sources
		    mv "${temp_dir}/linux" "${R}/usr/src/"

		    # Remove temporary directory for kernel sources
		    rm -fr "${temp_dir}"

		    # Set permissions of the kernel sources
		    chown -R root:root "${R}/usr/src"
	} fi

	# Calculate optimal number of kernel building threads
	if [ "$KERNEL_THREADS" = "1" ] && [ -r /proc/cpuinfo ] ; then
		KERNEL_THREADS=$(grep -c processor /proc/cpuinfo)
	fi

	# Configure and build kernel
	if [ "$KERNELSRC_PREBUILT" = false ] ; then
	{
	    # Remove device, network and filesystem drivers from kernel configuration
		if [ "$KERNEL_REDUCE" = true ] ; then
		{
			make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" "${KERNEL_DEFCONFIG}"
			sed -i\
			-e "s/\(^CONFIG_SND.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_SOUND.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_AC97.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_VIDEO_.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_MEDIA_TUNER.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_DVB.*\=\)[ym]/\1n/"\
			-e "s/\(^CONFIG_REISERFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_JFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_XFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_GFS2.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_OCFS2.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_BTRFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_HFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_JFFS2.*\=\)[ym]/\1n/"\
			-e "s/\(^CONFIG_UBIFS.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_SQUASHFS.*\=\)[ym]/\1n/"\
			-e "s/\(^CONFIG_W1.*\=\)[ym]/\1n/"\
			-e "s/\(^CONFIG_HAMRADIO.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_CAN.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_IRDA.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_BT_.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_WIMAX.*\=\)[ym]/\1n/"\
			-e "s/\(^CONFIG_6LOWPAN.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_IEEE802154.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_NFC.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_FB_TFT=.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_TOUCHSCREEN.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_USB_GSPCA_.*\=\).*/\1n/"\
			-e "s/\(^CONFIG_DRM.*\=\).*/\1n/"\
			"${KERNEL_DIR}/.config"
		} fi

		if [ "$KERNELSRC_CONFIG" = true ] ; then
		{
			# Load default raspberry kernel configuration
			make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" "${KERNEL_DEFCONFIG}"

			if [ ! -z "$KERNELSRC_USRCONFIG" ] ; then
				cp $KERNELSRC_USRCONFIG ${KERNEL_DIR}/.config
			fi

			# Start menu-driven kernel configuration (interactive)
			if [ "$KERNEL_MENUCONFIG" = true ] ; then
				make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" menuconfig
			fi
		} fi

		# Cross compile kernel and modules
		make -C "${KERNEL_DIR}" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" zImage modules dtbs
	} fi

	# Check if kernel compilation was successful
	if [ ! -r "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/zImage" ] ; then
	{
		echo "error: kernel compilation failed! (zImage not found)"
		cleanup
		exit 1
	} fi

	# Install kernel modules
	if [ "$ENABLE_REDUCE" = true ] ; then
	{
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../../.. modules_install
	}
	else
	{
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" INSTALL_MOD_PATH=../../.. modules_install

		# Install kernel firmware
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" INSTALL_FW_PATH=../../../lib firmware_install
	} fi

	# Install kernel headers
	if [ "$KERNEL_HEADERS" = true ] && [ "$KERNEL_REDUCE" = false ] ; then
	{
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" INSTALL_HDR_PATH=../.. headers_install
	} fi

	# Get kernel release version
	KERNEL_VERSION=`cat "${KERNEL_DIR}/include/config/kernel.release"`
	install_readonly "${KERNEL_DIR}/include/config/kernel.release" "${BOOT_DIR}"

	# Copy kernel configuration file to the boot directory
	install_readonly "${KERNEL_DIR}/.config" "${BOOT_DIR}/config-${KERNEL_VERSION}"

	# Copy dts and dtb device tree sources and binaries
	mkdir -p "${BOOT_DIR}/overlays"
	install_readonly "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/dts/"*.dtb "${BOOT_DIR}/"
	install_readonly "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/dts/overlays/"*.dtb* "${BOOT_DIR}/overlays/"
	install_readonly "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/dts/overlays/README" "${BOOT_DIR}/overlays/README"

	if [ "$ENABLE_UBOOT" = false ] ; then
	{
		# Convert and copy zImage kernel to the boot directory
		"${KERNEL_DIR}/scripts/mkknlimg" "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/zImage" "${BOOT_DIR}/${KERNEL_IMAGE}"
	}
	else
	{
		# Copy zImage kernel to the boot directory
		install_readonly "${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/zImage" "${BOOT_DIR}/${KERNEL_IMAGE}"
	} fi

	# Remove kernel sources
	if [ "$KERNEL_REMOVESRC" = true ] ; then
	{
		rm -fr "${KERNEL_DIR}"
	}
	else
	{
		make -C "${KERNEL_DIR}" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}-" modules_prepare

		# Create symlinks for kernel modules
		ln -sf "${KERNEL_DIR}" "${R}/lib/modules/${KERNEL_VERSION}/build"
		ln -sf "${KERNEL_DIR}" "${R}/lib/modules/${KERNEL_VERSION}/source"
	} fi
}
else
{
	if [  -d "${RPI_FIRMWARE_DIR}" ]; then
	{
		# Copy kernel and modules
		cp -r "${RPI_FIRMWARE_DIR}/boot" "${R}"
		cp -r "${RPI_FIRMWARE_DIR}/modules" "${R}/lib"
		
		#Get version
		KERNEL_VERSION="$(ls ${RPI_FIRMWARE_DIR}/modules | sort -r | head -1)"
		echo $KERNEL_VERSION > "${BOOT_DIR}/kernel.release"
	} 
	else 
	{
		echo "error: kernel not found"
		cleanup
		exit 1
	} fi     
} fi
