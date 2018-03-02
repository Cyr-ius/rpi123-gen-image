#
# Setup RPi1/2/3 config and cmdline
#

# Load utility functions
. ./functions.sh

if [ "$BUILD_KERNEL" = true  ] ; then
{
  if [ -d "$RPI_FIRMWARE_DIR" ]; then
  {  
   # Install boot binaries from local directory
    [ ! -f "${BOOT_DIR}/bootcode.bin" ] && cp ${RPI_FIRMWARE_DIR}/boot/bootcode.bin ${BOOT_DIR}/bootcode.bin
    [ ! -f "${BOOT_DIR}/fixup.dat" ] && cp ${RPI_FIRMWARE_DIR}/boot/fixup.dat ${BOOT_DIR}/fixup.dat
    [ ! -f "${BOOT_DIR}/fixup_cd.dat" ] && cp ${RPI_FIRMWARE_DIR}/boot/fixup_cd.dat ${BOOT_DIR}/fixup_cd.dat
    [ ! -f "${BOOT_DIR}/fixup_x.dat" ] && cp ${RPI_FIRMWARE_DIR}/boot/fixup_x.dat ${BOOT_DIR}/fixup_x.dat
    [ ! -f "${BOOT_DIR}/start.elf" ] && cp ${RPI_FIRMWARE_DIR}/boot/start.elf ${BOOT_DIR}/start.elf
    [ ! -f "${BOOT_DIR}/start_cd.elf" ] && cp ${RPI_FIRMWARE_DIR}/boot/start_cd.elf ${BOOT_DIR}/start_cd.elf
    [ ! -f "${BOOT_DIR}/start_x.elf" ] && cp ${RPI_FIRMWARE_DIR}/boot/start_x.elf ${BOOT_DIR}/start_x.elf
  }
  else
  {
    # Create temporary directory for boot binaries
    temp_dir=$(as_nobody mktemp -d)
    mkdir -p ${temp_dir}/boot

    # Install latest boot binaries from raspberry/firmware github
    as_nobody wget -q -O "${temp_dir}/boot/bootcode.bin" "${FIRMWARE_URL}/raw/master/boot/bootcode.bin"
    as_nobody wget -q -O "${temp_dir}/boot/fixup.dat" "${FIRMWARE_URL}/raw/master/boot/fixup.dat"
    as_nobody wget -q -O "${temp_dir}/boot/fixup_cd.dat" "${FIRMWARE_URL}/raw/master/boot/fixup_cd.dat"
    as_nobody wget -q -O "${temp_dir}/boot/fixup_x.dat" "${FIRMWARE_URL}/raw/master/boot/fixup_x.dat"
    as_nobody wget -q -O "${temp_dir}/boot/start.elf" "${FIRMWARE_URL}/raw/master/boot/start.elf"
    as_nobody wget -q -O "${temp_dir}/boot/start_cd.elf" "${FIRMWARE_URL}/raw/master/boot/start_cd.elf"
    as_nobody wget -q -O "${temp_dir}/boot/start_x.elf" "${FIRMWARE_URL}/raw/master/boot/start_x.elf"

    # Move downloaded boot binaries
    mv "${temp_dir}/"* "${BOOT_DIR}/"

    # Remove temporary directory for boot binaries
    rm -fr "${temp_dir}"

    # Set permissions of the boot binaries
    chown -R root:root "${BOOT_DIR}"
    chmod -R 600 "${BOOT_DIR}"
  } fi
} fi

# Setup firmware boot cmdline
if [ "$ENABLE_SPLITFS" = true ] ; then
  CMDLINE="dwc_otg.lpm_enable=0 dwc_otg.fiq_fix_enable=1 sdhci-bcm2708.sync_after_dma=0 root=/dev/sda1 rootfstype=ext4 elevator=deadline rootwait console=tty1 fsck.repair=yes logo.nologo"
else
  CMDLINE="dwc_otg.lpm_enable=0 dwc_otg.fiq_fix_enable=1 sdhci-bcm2708.sync_after_dma=0 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait console=tty1 fsck.repair=yes logo.nologo"
fi

# Add encrypted root partition to cmdline.txt
if [ "$ENABLE_CRYPTFS" = true ] ; then
  if [ "$ENABLE_SPLITFS" = true ] ; then
    CMDLINE=$(echo ${CMDLINE} | sed "s/sda1/mapper\/${CRYPTFS_MAPPING} cryptdevice=\/dev\/sda1:${CRYPTFS_MAPPING}/")
  else
    CMDLINE=$(echo ${CMDLINE} | sed "s/mmcblk0p2/mapper\/${CRYPTFS_MAPPING} cryptdevice=\/dev\/mmcblk0p2:${CRYPTFS_MAPPING}/")
  fi
fi

# Add serial console support
if [ "$ENABLE_CONSOLE" = true ] ; then
  CMDLINE="${CMDLINE} console=ttyAMA0,115200 kgdboc=ttyAMA0,115200"
fi

# Remove IPv6 networking support
if [ "$ENABLE_IPV6" = false ] ; then
  CMDLINE="${CMDLINE} ipv6.disable=1"
fi

# Automatically assign predictable network interface names
if [ "$ENABLE_IFNAMES" = false ] ; then
  CMDLINE="${CMDLINE} net.ifnames=0 bios.devname=0"
else
  CMDLINE="${CMDLINE} net.ifnames=1"
fi

# Set init to systemd if required by Debian release
if [ "$RELEASE" = "stretch" ] || [ "$RELEASE" = "buster" ] ; then
  CMDLINE="${CMDLINE} init=/bin/systemd"
fi

# Disable blinking cursor on splashscreen
if [ "$ENABLE_SPLASHSCREEN" = true ]; then
  CMDLINE="${CMDLINE} vt.global_cursor_default=0 quiet splash plymouth.ignore-serial-consoles"
  echo "disable_splash=1" >> "${BOOT_DIR}/config.txt" 
fi

# Install firmware boot cmdline
echo "${CMDLINE}" > "${BOOT_DIR}/cmdline.txt"

# Install firmware config
install_readonly files/boot/config.txt "${BOOT_DIR}/config.txt"

# Setup minimal GPU memory allocation size: 16MB (no X)
if [ "$ENABLE_MINGPU" = true ] ; then
  echo "gpu_mem=16" >> "${BOOT_DIR}/config.txt"
else
  # Optimize settings
  echo "gpu_mem=16" >> "${BOOT_DIR}/config.txt"
  echo "gpu_mem_512=128" >> "${BOOT_DIR}/config.txt"
  echo "gpu_mem_1024=256" >> "${BOOT_DIR}/config.txt"
  echo "disable_overscan=1" >> "${BOOT_DIR}/config.txt"
  echo "start_x=1" >> "${BOOT_DIR}/config.txt"
  echo "dtoverlay=lirc-rpi:gpio_out_pin=17,gpio_in_pin=18" >> "${BOOT_DIR}/config.txt"
fi

# Setup boot with initramfs
if [ "$ENABLE_INITRAMFS" = true ] ; then
  KERNEL_VERSION=$(cat ${R}/boot/kernel.release)
  echo "initramfs initrd.img-${KERNEL_VERSION} followkernel" >> "${BOOT_DIR}/config.txt"
fi

# Disable RPi3 Bluetooth and restore ttyAMA0 serial device
if [ "$RPI_MODEL" = 3 ] ; then
  if [ "$ENABLE_CONSOLE" = true ] && [ "$ENABLE_UBOOT" = false ] ; then
    echo "dtoverlay=pi3-disable-bt" >> "${BOOT_DIR}/config.txt"
    echo "enable_uart=1" >> "${BOOT_DIR}/config.txt"
  fi
fi

# Install and setup kernel modules to load at boot
mkdir -p "${R}/lib/modules-load.d/"
install_readonly files/modules/rpi.conf "${R}/lib/modules-load.d/rpi.conf"

# Load sound module at boot
if [ "$ENABLE_SOUND" = true ] ; then
  sed -i "s/^# snd_bcm2835/snd_bcm2835/" "${R}/lib/modules-load.d/rpi.conf"
else
  echo "dtparam=audio=off" >> "${BOOT_DIR}/config.txt"
fi

# Enable I2C interface
if [ "$ENABLE_I2C" = true ] ; then
  echo "dtparam=i2c_arm=on" >> "${BOOT_DIR}/config.txt"
  sed -i "s/^# i2c-bcm2708/i2c-bcm2708/" "${R}/lib/modules-load.d/rpi.conf"
  sed -i "s/^# i2c-dev/i2c-dev/" "${R}/lib/modules-load.d/rpi.conf"
fi

# Enable SPI interface
if [ "$ENABLE_SPI" = true ] ; then
  echo "dtparam=spi=on" >> "${BOOT_DIR}/config.txt"
  echo "spi-bcm2708" >> "${R}/lib/modules-load.d/rpi.conf"
  if [ "$RPI_MODEL" = 3 ] ; then
    sed -i "s/spi-bcm2708/spi-bcm2835/" "${R}/lib/modules-load.d/rpi.conf"
  fi
fi

# Disable RPi1/2/3 under-voltage warnings
if [ ! -z "$DISABLE_UNDERVOLT_WARNINGS" ] ; then
  echo "avoid_warnings=${DISABLE_UNDERVOLT_WARNINGS}" >> "${BOOT_DIR}/config.txt"
fi

# Install kernel modules blacklist
mkdir -p "${ETC_DIR}/modprobe.d/"
install_readonly files/modules/raspi-blacklist.conf "${ETC_DIR}/modprobe.d/raspi-blacklist.conf"

# Install sysctl.d configuration files
install_readonly files/sysctl.d/81-rpi-vm.conf "${ETC_DIR}/sysctl.d/81-rpi-vm.conf"

if [ -z "$APT_INCLUDES_KERNEL"] && [ -d "$RPI_FIRMWARE_DIR" ]; then
  # Move downloaded firmware binary blob
  [ $RPI_MODEL = 0 ] || [ $RPI_MODEL = 1 ] &&  cp -r "${RPI_FIRMWARE_DIR}/opt/vc" "${R}/opt"
  [ $RPI_MODEL = 2 ] || [ $RPI_MODEL = 3 ] &&  cp -r "${RPI_FIRMWARE_DIR}/hardfp/opt/vc" "${R}/opt"

  # Install VC libraries
  echo "/opt/vc/lib" > "${ETC_DIR}/ld.so.conf.d/00-vmcs.conf"
fi

# Install rules for udev
install_readonly files/udev/* "${ETC_DIR}/udev/rules.d/"
