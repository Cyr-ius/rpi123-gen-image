#!/bin/bash

########################################################################
# rpi123-gen-image.sh					       2015-2017
#
# Advanced Debian "jessie" and "stretch"  bootstrap script for RPi1/2/3
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Orginal Author : Jan Wagner <mail@jwagner.eu>
#
# Copyright (C) 2017 Cédric Levasseur <cedric.levasseur@ipocus.net>
#
# Big thanks for patches and enhancements by 10+ github contributors!
########################################################################

# Are we running as root?
if [ "$(id -u)" -ne "0" ] ; then
  echo "error: this script must be executed with root privileges!"
  exit 1
fi

# Check if ./functions.sh script exists
if [ ! -r "./functions.sh" ] ; then
  echo "error: './functions.sh' required script not found!"
  exit 1
fi

# Load utility functions
. ./functions.sh

# Load parameters from configuration template file
if [ ! -z "$CONFIG_TEMPLATE" ] ; then
  use_template
fi

# Introduce settings
set -e
echo -n -e "\n#\n# RPi1/2/3 Bootstrap Settings\n#\n"
set -x

# Default Raspberry Pi model configuration
RPI_MODEL=${RPI_MODEL:=2}
if [[ ! "$RPI_MODEL" =~ "0"|"1"|"2"|"3"|"3x64" ]];then
  echo "error: Raspberry Pi model ${RPI_MODEL} is not supported!"
  exit 1
else
  build_env $RPI_MODEL
fi

# Debian release
RELEASE=${RELEASE:=stretch}
QEMU_BINARY=${QEMU_BINARY:=/usr/bin/qemu-arm-static}

# URLs
KERNEL_URL=${KERNEL_URL:=https://github.com/raspberrypi/linux.git}
FIRMWARE_URL=${FIRMWARE_URL:=https://github.com/raspberrypi/firmware.git}
TOOLS_URL=${TOOLS_URL:=https://github.com/raspberrypi/tools.git}
WLAN_FIRMWARE_URL=${WLAN_FIRMWARE_URL:=https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm}
FBTURBO_URL=${FBTURBO_URL:=https://github.com/ssvb/xf86-video-fbturbo.git}
UBOOT_URL=${UBOOT_URL:=git://git.denx.de/u-boot.git}

# Build directories
BASEDIR=${BASEDIR:=$(pwd)/images/${RELEASE}}
BUILDDIR="${BASEDIR}/build"

#Cleaning building directories and files flags
RESET=${RESET:=false}

#Cleaning flags
CLEAN=${CLEAN:=false}

# Chroot directories
R="${BUILDDIR}/chroot"
ETC_DIR="${R}/etc"
LIB_DIR="${R}/lib"
BOOT_DIR="${R}/boot"
KERNEL_DIR="${R}/usr/src/linux"
WLAN_FIRMWARE_DIR="${R}/lib/firmware/brcm"

# Firmware directory: Blank if download from github
RPI_FIRMWARE_DIR=${RPI_FIRMWARE_DIR:=${BUILDDIR}/firmware}
#~ TOOLS_DIR=${TOOLS_DIR:=$(pwd)/tools}
#~ DEB_PACKAGES=${DEB_PACKAGES:="$(pwd)/deb-packages"}
NOOBS_DIR=${NOOBS_DIR:=$(pwd)/noobs}

# General settings
HOST_NAME=${HOST_NAME:=rbp${RPI_MODEL}}
USER_NAME=${USER_NAME:="pi"}
PASSWORD=${PASSWORD:=raspberry}
USER_PASSWORD=${USER_PASSWORD:=raspberry}
DEFLOCAL=${DEFLOCAL:="en_US.UTF-8"}
TIMEZONE=${TIMEZONE:="Europe/Berlin"}
EXPANDROOT=${EXPANDROOT:=true}

#Execute custom's scripts in the folder named custo.d
ENABLE_CUSTOMIZE=${ENABLE_CUSTOMIZE:=true}

# Prepare date string for default image file name
DATE="$(date +%Y-%m-%d)"
IMAGE_NAME=${IMAGE_NAME:=${BASEDIR}/${HOST_NAME}-${RELEASE}-${DATE}}

# Keyboard settings
XKB_MODEL=${XKB_MODEL:=""}
XKB_LAYOUT=${XKB_LAYOUT:=""}
XKB_VARIANT=${XKB_VARIANT:=""}
XKB_OPTIONS=${XKB_OPTIONS:=""}

# Network settings (DHCP)
ENABLE_DHCP=${ENABLE_DHCP:=true}

# Network settings (static)
NET_ADDRESS=${NET_ADDRESS:=""}
NET_GATEWAY=${NET_GATEWAY:=""}
NET_DNS_1=${NET_DNS_1:=""}
NET_DNS_2=${NET_DNS_2:=""}
NET_DNS_DOMAINS=${NET_DNS_DOMAINS:=""}
NET_NTP_1=${NET_NTP_1:=""}
NET_NTP_2=${NET_NTP_2:=""}

# APT settings
ENABLE_RASPBIAN=${ENABLE_RASPBIAN:=true}
ENABLE_IPOCUS=${ENABLE_IPOCUS:=true}
APT_PROXY=${APT_PROXY:=""}
APT_SERVER=${APT_SERVER:="http://ftp.debian.org/debian"}
[ "$ENABLE_RASPBIAN" = true ] && APT_SERVER="http://mirrordirector.raspbian.org/raspbian"

# Feature settings
ENABLE_FIRMWARE=${ENABLE_FIRMWARE:=true}
ENABLE_CONSOLE=${ENABLE_CONSOLE:=true}
ENABLE_I2C=${ENABLE_I2C:=false}
ENABLE_SPI=${ENABLE_SPI:=false}
ENABLE_IPV6=${ENABLE_IPV6:=true}
ENABLE_SSHD=${ENABLE_SSHD:=true}
ENABLE_NONFREE=${ENABLE_NONFREE:=false}
ENABLE_WIRELESS=${ENABLE_WIRELESS:=false}
ENABLE_BLUETOOTH=${ENABLE_BLUETOOTH:=false}
ENABLE_SOUND=${ENABLE_SOUND:=true}
ENABLE_DBUS=${ENABLE_DBUS:=true}
ENABLE_HWRANDOM=${ENABLE_HWRANDOM:=true}
ENABLE_MINGPU=${ENABLE_MINGPU:=false}
ENABLE_XORG=${ENABLE_XORG:=false}
ENABLE_WM=${ENABLE_WM:=""}
ENABLE_RSYSLOG=${ENABLE_RSYSLOG:=true}
ENABLE_USER=${ENABLE_USER:=true}
ENABLE_ROOT=${ENABLE_ROOT:=false}
ENABLE_SPLASHSCREEN=${ENABLE_SPLASHSCREEN:=false}

#Kodi Mediacenter
ENABLE_KODI=${ENABLE_KODI:=false}
ENABLE_KODI_AUTOSTART=${ENABLE_KODI_AUTOSTART:=false}
ENABLE_KODI_SPLASHSCREEN=${ENABLE_KODI_SPLASHSCREEN:=false}

# SSH settings
SSH_ENABLE_ROOT=${SSH_ENABLE_ROOT:=false}
SSH_DISABLE_PASSWORD_AUTH=${SSH_DISABLE_PASSWORD_AUTH:=false}
SSH_LIMIT_USERS=${SSH_LIMIT_USERS:=false}
SSH_ROOT_PUB_KEY=${SSH_ROOT_PUB_KEY:=""}
SSH_USER_PUB_KEY=${SSH_USER_PUB_KEY:=""}

# Advanced settings
ENABLE_MINBASE=${ENABLE_MINBASE:=false}
ENABLE_REDUCE=${ENABLE_REDUCE:=false}
ENABLE_UBOOT=${ENABLE_UBOOT:=false}
UBOOTSRC_DIR=${UBOOTSRC_DIR:=""}
ENABLE_FBTURBO=${ENABLE_FBTURBO:=false}
FBTURBOSRC_DIR=${FBTURBOSRC_DIR:=""}
ENABLE_HARDNET=${ENABLE_HARDNET:=false}
ENABLE_IPTABLES=${ENABLE_IPTABLES:=false}
ENABLE_SPLITFS=${ENABLE_SPLITFS:=false}
ENABLE_INITRAMFS=${ENABLE_INITRAMFS:=false}
ENABLE_IFNAMES=${ENABLE_IFNAMES:=false}
DISABLE_UNDERVOLT_WARNINGS=${DISABLE_UNDERVOLT_WARNINGS:=}
CREATE_TARBALL=${CREATE_TARBALL:=false}
CREATE_NOOBS=${CREATE_NOOBS:=false}

# Kernel compilation settings
BUILD_KERNEL=${BUILD_KERNEL:=false}
KERNEL_REDUCE=${KERNEL_REDUCE:=false}
KERNEL_THREADS=${KERNEL_THREADS:=1}
KERNEL_HEADERS=${KERNEL_HEADERS:=true}
KERNEL_MENUCONFIG=${KERNEL_MENUCONFIG:=false}
KERNEL_REMOVESRC=${KERNEL_REMOVESRC:=true}
KERNEL_INSTALLPACKAGES=${KERNEL_INSTALLPACKAGES:=false}

# Kernel compilation from source directory settings
KERNELSRC_DIR=${KERNELSRC_DIR:=""}
KERNELSRC_CLEAN=${KERNELSRC_CLEAN:=false}
KERNELSRC_CONFIG=${KERNELSRC_CONFIG:=true}
KERNELSRC_PREBUILT=${KERNELSRC_PREBUILT:=false}

# Reduce disk usage settings
REDUCE_APT=${REDUCE_APT:=true}
REDUCE_DOC=${REDUCE_DOC:=true}
REDUCE_MAN=${REDUCE_MAN:=true}
REDUCE_VIM=${REDUCE_VIM:=false}
REDUCE_BASH=${REDUCE_BASH:=false}
REDUCE_HWDB=${REDUCE_HWDB:=true}
REDUCE_SSHD=${REDUCE_SSHD:=true}
REDUCE_LOCALE=${REDUCE_LOCALE:=true}

# Encrypted filesystem settings
ENABLE_CRYPTFS=${ENABLE_CRYPTFS:=false}
CRYPTFS_PASSWORD=${CRYPTFS_PASSWORD:=""}
CRYPTFS_MAPPING=${CRYPTFS_MAPPING:="secure"}
CRYPTFS_CIPHER=${CRYPTFS_CIPHER:="aes-xts-plain64:sha512"}
CRYPTFS_XTSKEYSIZE=${CRYPTFS_XTSKEYSIZE:=512}

# Stop the Crypto Wars
DISABLE_FBI=${DISABLE_FBI:=false}

# Chroot scripts directory
CHROOT_SCRIPTS=${CHROOT_SCRIPTS:=""}

# Packages required in the chroot build environment
APT_INCLUDES=${APT_INCLUDES:=""}
APT_INCLUDES="${APT_INCLUDES} apt-transport-https apt-utils ca-certificates debian-archive-keyring dialog sudo systemd sysvinit-utils fake-hwclock net-tools bash-completion systemd-sysv"

# Packages required for bootstrapping
REQUIRED_PACKAGES="debootstrap debian-archive-keyring qemu-user-static binfmt-support dosfstools rsync bmap-tools whois git bc psmisc dbus sudo"
MISSING_PACKAGES=""

# Packages installed for c/c++ build environment in chroot (keep empty)
COMPILER_PACKAGES=""

set +x

# Add packages required for kernel cross compilation
if [ "$BUILD_KERNEL" = true ] ; then
  REQUIRED_PACKAGES="${REQUIRED_PACKAGES} crossbuild-essential-armhf crossbuild-essential-armel crossbuild-essential-arm64"
fi

# Add libncurses5 to enable kernel menuconfig
if [ "$KERNEL_MENUCONFIG" = true ] ; then
  REQUIRED_PACKAGES="${REQUIRED_PACKAGES} libncurses5-dev"
fi

# Stop the Crypto Wars
if [ "$DISABLE_FBI" = true ] ; then
  ENABLE_CRYPTFS=true
fi

# Add fbturbo video driver
if [ "$ENABLE_FBTURBO" = true ] ; then
  ENABLE_XORG=true
fi

#Disable buildkernel if  APT_INCLUDES_KERNEL is not empty
if [ ! -z "$APT_INCLUDES_KERNEL" ] ; then
  BUILD_KERNEL=false 
fi

# Configure kernel sources if no KERNELSRC_DIR
if [ "$BUILD_KERNEL" = true ] && [ -z "$KERNELSRC_DIR" ] ; then
  KERNELSRC_CONFIG=true
fi

# Configure reduced kernel
if [ "$KERNEL_REDUCE" = true ] ; then
  KERNELSRC_CONFIG=false
fi

# Add cryptsetup package to enable filesystem encryption
if [ "$ENABLE_CRYPTFS" = true ]  && [ "$BUILD_KERNEL" = true ] ; then
  REQUIRED_PACKAGES="${REQUIRED_PACKAGES} cryptsetup"
  if [ -z "$CRYPTFS_PASSWORD" ] ; then
    echo "error: no password defined (CRYPTFS_PASSWORD)!"
    exit 1
  fi
  ENABLE_INITRAMFS=true
fi

# Add cryptsetup package to enable filesystem encryption
if [ "$ENABLE_CRYPTFS" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} cryptsetup busybox"
fi

# Add device-tree-compiler required for building the U-Boot bootloader
if [ "$ENABLE_UBOOT" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} device-tree-compiler"
fi

# Add required packages for the minbase installation
if [ "$ENABLE_MINBASE" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} vim-tiny netbase net-tools ifupdown rsyslog logrotate"
fi

# Add required locales packages
if [ "$DEFLOCAL" != "en_US.UTF-8" ] ; then
  APT_INCLUDES="${APT_INCLUDES} locales keyboard-configuration console-setup"
fi

# Add parted package, required to get partprobe utility
if [ "$EXPANDROOT" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} parted"
fi

# Add dbus package, recommended if using systemd
if [ "$ENABLE_DBUS" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} dbus"
fi

# Add iptables IPv4/IPv6 package
if [ "$ENABLE_IPTABLES" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} iptables"
fi

# Add openssh server package
if [ "$ENABLE_SSHD" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} openssh-server"
fi

# Add alsa-utils package
if [ "$ENABLE_SOUND" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} alsa-utils"
fi

# Add rng-tools package
if [ "$ENABLE_HWRANDOM" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} rng-tools"
fi

# Add user defined window manager package
if [ -n "$ENABLE_WM" ] ; then
  APT_INCLUDES="${APT_INCLUDES} ${ENABLE_WM}"
  ENABLE_XORG=true
fi

# Add xorg package
if [ "$ENABLE_XORG" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} xorg dbus-x11"
fi

# Add Kodi splashscreen
if [ "$ENABLE_KODI_SPLASHSCREEN" = true ]; then
  ENABLE_SPLASHSCREEN=true
fi

# Add plymouth & plymouth's theme package
if [ "$ENABLE_SPLASHSCREEN" = true ] && [ "$ENABLE_INITRAMFS" = true ]; then
  APT_INCLUDES="${APT_INCLUDES} plymouth plymouth-themes"
fi

# Add Kodi package
if [ "$ENABLE_KODI" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} kodi kodi-bin kodi-audioencoder-wav kodi-audioencoder-vorbis kodi-audioencoder-lame kodi-audioencoder-flac kodi-audiodecoder-vgmstream kodi-audiodecoder-timidity kodi-audiodecoder-stsound kodi-audiodecoder-snesapu kodi-audiodecoder-sidplay kodi-audiodecoder-nosefart kodi-audiodecoder-modplug kodi-pvr-vuplus kodi-pvr-vdr-vnsi kodi-pvr-vbox kodi-pvr-stalker kodi-pvr-pctv kodi-pvr-njoy kodi-pvr-nextpvr kodi-pvr-mythtv kodi-pvr-mythtv kodi-pvr-iptvsimple kodi-pvr-hts kodi-pvr-hdhomerun kodi-pvr-filmon kodi-pvr-dvbviewer kodi-pvr-dvblink kodi-pvr-demo kodi-pvr-argustv kodi-inputstream-rtmp kodi-inputstream-adaptive kodi-inputstream-rtmp kodi-inputstream-adaptive libsmbclient python-apt python-aptdaemon libcec"
fi

# Add service and watchdog for kodi at startup
if [ "$ENABLE_KODI_AUTOSTART" = true ]  && [ "$ENABLE_KODI" = true ]; then
  APT_INCLUDES="${APT_INCLUDES} policykit-1 libcap2-bin fbset"
fi

# Add wireless packages
if [ "$ENABLE_WIRELESS" = true ]; then
  APT_INCLUDES="${APT_INCLUDES} wpasupplicant wireless-tools wireless-regdb firmware-brcm80211"
fi

# Add bluetooth packages
if [ "$ENABLE_BLUETOOTH" = true ]; then
  APT_INCLUDES="${APT_INCLUDES} bluez bluez-firmware"
fi

# Add optimization pack for Raspbian
if [ "$ENABLE_RASPBIAN" = true ]; then
  APT_INCLUDES="${APT_INCLUDES} raspi-copies-and-fills raspi-config"
fi

# Replace selected packages with smaller clones
if [ "$ENABLE_REDUCE" = true ] ; then
  # Add levee package instead of vim-tiny
  if [ "$REDUCE_VIM" = true ] ; then
    APT_INCLUDES="$(echo ${APT_INCLUDES} | sed "s/vim-tiny/levee/")"
  fi

  # Add dropbear package instead of openssh-server
  if [ "$REDUCE_SSHD" = true ] ; then
    APT_INCLUDES="$(echo ${APT_INCLUDES} | sed "s/openssh-server/dropbear/")"
  fi
fi

# Add initramfs generation tools
if [ "$ENABLE_INITRAMFS" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} initramfs-tools"
fi

################################# Check integrity ####################################

# Check if root SSH (v2) public key file exists
if [ ! -z "$SSH_ROOT_PUB_KEY" ] ; then
  if [ ! -f "$SSH_ROOT_PUB_KEY" ] ; then
    echo "error: '$SSH_ROOT_PUB_KEY' specified SSH public key file not found (SSH_ROOT_PUB_KEY)!"
    exit 1
  fi
fi

# Check if $USER_NAME SSH (v2) public key file exists
if [ ! -z "$SSH_USER_PUB_KEY" ] ; then
  if [ ! -f "$SSH_USER_PUB_KEY" ] ; then
    echo "error: '$SSH_USER_PUB_KEY' specified SSH public key file not found (SSH_USER_PUB_KEY)!"
    exit 1
  fi
fi

# Check if all required packages are installed on the build system
for package in $REQUIRED_PACKAGES ; do
  if [ "`dpkg-query -W -f='${Status}' $package`" != "install ok installed" ] ; then
    MISSING_PACKAGES="${MISSING_PACKAGES} $package"
  fi
done

# If there are missing packages ask confirmation for install, or exit
if [ -n "$MISSING_PACKAGES" ] ; then
  echo "the following packages needed by this script are not installed:"
  echo "$MISSING_PACKAGES"
  echo -n "\ndo you want to install the missing packages right now? [y/n] "
  read confirm
  [ "$confirm" != "y" ] && exit 1

  # Make sure all missing required packages are installed
  apt-get -qq -y install ${MISSING_PACKAGES}
fi

# Check if ./bootstrap.d directory exists
if [ ! -d "./bootstrap.d/" ] ; then
  echo "error: './bootstrap.d' required directory not found!"
  exit 1
fi

# Check if ./files directory exists
if [ ! -d "./files/" ] ; then
  echo "error: './files' required directory not found!"
  exit 1
fi

# Check if specified KERNELSRC_DIR directory exists
if [ -n "$KERNELSRC_DIR" ] && [ ! -d "$KERNELSRC_DIR" ] ; then
  echo "error: '${KERNELSRC_DIR}' specified directory not found (KERNELSRC_DIR)!"
  exit 1
fi

# Check if specified UBOOTSRC_DIR directory exists
if [ -n "$UBOOTSRC_DIR" ] && [ ! -d "$UBOOTSRC_DIR" ] ; then
  echo "error: '${UBOOTSRC_DIR}' specified directory not found (UBOOTSRC_DIR)!"
  exit 1
fi

# Check if specified FBTURBOSRC_DIR directory exists
if [ -n "$FBTURBOSRC_DIR" ] && [ ! -d "$FBTURBOSRC_DIR" ] ; then
  echo "error: '${FBTURBOSRC_DIR}' specified directory not found (FBTURBOSRC_DIR)!"
  exit 1
fi

# Check if specified CHROOT_SCRIPTS directory exists
if [ -n "$CHROOT_SCRIPTS" ] && [ ! -d "$CHROOT_SCRIPTS" ] ; then
   echo "error: ${CHROOT_SCRIPTS} specified directory not found (CHROOT_SCRIPTS)!"
   exit 1
fi

# Check if specified device mapping already exists (will be used by cryptsetup)
if [ -r "/dev/mapping/${CRYPTFS_MAPPING}" ] ; then
  echo "error: mapping /dev/mapping/${CRYPTFS_MAPPING} already exists, not proceeding"
  exit 1
fi

#Check if initramfs is enable with splashscreen
if [ "$ENABLE_SPLASHSCREEN" = true ] && [ "$ENABLE_INITRAMFS" = false ]; then
  echo "error: for enable spalshscreen, please enable initramfs"
  exit 1
fi

# Clean all flags, building folder and sources
if [ "$RESET" = true ]; then
  echo "Reset flags in bootstrap.d and custom.d and delete firmware and tools folders"
  [ -d "bootstrap.d/flags" ] && rm -rf bootstrap.d/flags
  [ -d "custom.d/flags" ] && rm -rf custom.d/flags
  #~ [ -d "${TOOLS_DIR}" ] && rm -rf ${TOOLS_DIR}
  [ -d "packages" ] && rm -rf packages
  [ -d "${BUILDDIR}" ] && rm -rf ${BUILDDIR}  
fi

set -x

################################# Main ####################################

# Call "cleanup" function on various signals and errors
trap cleanup 0 1 2 3 6

# Clean all flags  and building folder
if [ "$CLEAN" = true ]; then
  echo "Reset flags in bootstrap.d and custom.d folders"
  [ -d "bootstrap.d/flags" ] && rm -rf bootstrap.d/flags
  [ -d "custom.d/flags" ] && rm -rf custom.d/flags
  [ -d "${R}" ] && rm -rf "${R}"
fi

# Check if build directory has enough of free disk space >512MB
if [ "$(df --output=avail ${BUILDDIR} | sed "1d")" -le "524288" ] ; then
  echo "error: ${BUILDDIR} not enough space left to generate the output image!"
  exit 1
fi

# Setup chroot directory
mkdir -p "${R}" && chmod ugo+rw "${R}"

# Execute bootstrap scripts
mkdir -p "bootstrap.d/flags" && chmod o+rw "bootstrap.d/flags"
for SCRIPT in bootstrap.d/*.sh; do
  head -n 3 "$SCRIPT"
  FLAG=$(basename "$SCRIPT")
  if [ ! -f "bootstrap.d/flags/${FLAG%.*}" ]; then
    . "$SCRIPT"
    touch "bootstrap.d/flags/${FLAG%.*}"
  fi
done

# Execute custom bootstrap scripts
mkdir -p "custom.d/flags" && chmod o+rw "custom.d/flags"
if [ -d "custom.d" ] && [ "$ENABLE_CUSTOMIZE" = "true" ]; then
  for SCRIPT in custom.d/*.sh; do
    FLAG=$(basename "$SCRIPT")
    if [ ! -f "custom.d/flags/${FLAG%.*}" ]; then
      . "$SCRIPT"
      touch "custom.d/flags/${FLAG%.*}"
    fi
  done
fi

# Execute custom scripts inside the chroot
if [ -n "$CHROOT_SCRIPTS" ] && [ -d "$CHROOT_SCRIPTS" ] ; then
  cp -r "${CHROOT_SCRIPTS}" "${R}/chroot_scripts"
  chroot_exec /bin/bash -x <<'EOF'
for SCRIPT in /chroot_scripts/* ; do
  if [ -f $SCRIPT -a -x $SCRIPT ] ; then
    $SCRIPT
  fi
done
EOF
  rm -rf "${R}/chroot_scripts"
fi

################################# Finalize and prepare image ####################################

# Remove c/c++ build environment from the chroot
chroot_remove_cc

# Remove apt-utils
if [ "$RELEASE" = "jessie" ] ; then
  chroot_exec apt-get purge -qq -y --force-yes apt-utils
fi

# Generate required machine-id
MACHINE_ID=$(dbus-uuidgen)
echo -n "${MACHINE_ID}" > "${R}/var/lib/dbus/machine-id"
echo -n "${MACHINE_ID}" > "${ETC_DIR}/machine-id"

# OS Release
NAME="GNU/Linux Raspbian"
VERSION=$(awk '/VERSION=/ {split($0,a,"\""); print a[2]}' ${R}/usr/lib/os-release)
sed "/^NAME/c\NAME=\"$NAME\"" -i ${R}/usr/lib/os-release
sed "/^PRETTY/c\PRETTY_NAME=\"$NAME $VERSION\"" -i ${R}/usr/lib/os-release
sed "/^HOME_URL/c\HOME_URL=\"https://github.com/cyr-ius/rpi123-gen-image/wiki\"" -i ${R}/usr/lib/os-release
sed "/^SUPPORT_URL/d" -i ${R}/usr/lib/os-release
sed "/^BUG_REPORT_URL/d" -i ${R}/usr/lib/os-release

# APT Cleanup
chroot_exec apt-get -y clean
chroot_exec apt-get -y autoclean
chroot_exec apt-get -y autoremove

# Unmount mounted filesystems
[[ `grep "${R}/proc" /proc/mounts` ]] && umount -l "${R}/proc"
[[ `grep "${R}/sys"  /proc/mounts` ]] && umount -l "${R}/sys"

# Clean up directories
rm -rf "${R}/run/*"
rm -rf "${R}/tmp/*"

# Clean up files
rm -f "${ETC_DIR}/ssh/ssh_host_*"
rm -f "${ETC_DIR}/dropbear/dropbear_*"
rm -f "${ETC_DIR}/apt/sources.list.save"
rm -f "${ETC_DIR}/resolvconf/resolv.conf.d/original"
rm -f "${ETC_DIR}/*-"
rm -f "${ETC_DIR}/apt/apt.conf.d/10proxy"
rm -f "${ETC_DIR}/resolv.conf"
rm -f "${R}/root/.bash_history"
rm -f "${R}/var/lib/urandom/random-seed"
rm -f "${R}/initrd.img"
rm -f "${R}/vmlinuz"
rm -f "${R}${QEMU_BINARY}"

#Fix preload ARM-MEM
if [ -e "${ETC_DIR}/ld.so.preload.disabled" ]; then
        mv "${ETC_DIR}/ld.so.preload.disabled" "${ETC_DIR}/ld.so.preload"
fi

#Create TAR Filesystem
if [ "$CREATE_TARBALL" = true ] ; then
	create_fs_tarball "${R}" "$IMAGE_NAME-filesystem"
fi

#Create NOOBS Installer
if [ "$CREATE_NOOBS" = true ] ; then
        echo -e "Building NOOBS filesystem image"
        NOOBS_OS="${NOOBS_DIR}/${HOST_NAME}"
        rm -rf "$NOOBS_OS"
	mkdir -p "$NOOBS_OS"
        chmod ugo+rw $NOOBS_OS
	
        echo -e "Creating Boot tarball"
	pushd "${R}/boot" 
	UNC_TS_SIZE_BOOT=$(du -h --max-depth=0 . | awk {'print $1'} | tr -d 'M')
	echo "noobs" > vendor
	tar -cf - * | xz -9 -c - > "$NOOBS_OS/boot.tar.xz"
	popd

        echo -e "Creating System tarball"
	pushd "${R}" 
	UNC_TS_SIZE_ROOT=$(du -h --max-depth=0 . | awk {'print $1'} | tr -d 'M')
	tar --exclude='boot' -cf - * | xz -9 -c - > "$NOOBS_OS/root.tar.xz"
	popd	        
        
	cp ${NOOBS_DIR}/partitions.json $NOOBS_OS/partitions.json	
	sed -e s/#UNC_TS_SIZE_BOOT#/${UNC_TS_SIZE_BOOT}/  -i $NOOBS_OS/partitions.json
	sed -e s/#UNC_TS_SIZE_ROOT#/${UNC_TS_SIZE_ROOT}/ -i $NOOBS_OS/partitions.json
	
	cp ${NOOBS_DIR}/os.json $NOOBS_OS/os.json
	sed -e s/#HOSTNAME#/$HOST_NAME/ -i $NOOBS_OS/os.json
	sed -e s/#DATE#/$DATE/ -i $NOOBS_OS/os.json	
	sed -e s/#KERNEL#/$KERNEL/ -i $NOOBS_OS/os.json
	sed -e s/#USER_NAME#/$USER_NAME/ -i $NOOBS_OS/os.json
	sed -e s/#USER_PASSWORD#/$USER_PASSWORD/ -i $NOOBS_OS/os.json
        
	cp -R ${NOOBS_DIR}/slides_vga $NOOBS_OS/
	cp ${NOOBS_DIR}/${HOST_NAME}.png $NOOBS_OS/
	cp ${NOOBS_DIR}/partition_setup.sh $NOOBS_OS/
	cp ${NOOBS_DIR}/release_notes.txt $NOOBS_OS/
fi


# Calculate size of the chroot directory in KB
CHROOT_SIZE=$(expr `du -s "${R}" | awk '{ print $1 }'`)

# Calculate the amount of needed 512 Byte sectors
TABLE_SECTORS=$(expr 1 \* 1024 \* 1024 \/ 512)
FRMW_SECTORS=$(expr 128 \* 1024 \* 1024 \/ 512)
ROOT_OFFSET=$(expr ${TABLE_SECTORS} + ${FRMW_SECTORS})

# The root partition is EXT4
# This means more space than the actual used space of the chroot is used.
# As overhead for journaling and reserved blocks 25% are added.
ROOT_SECTORS=$(expr $(expr ${CHROOT_SIZE} + ${CHROOT_SIZE} \/ 100 \* 25) \* 1024 \/ 512)

# Calculate required image size in 512 Byte sectors
IMAGE_SECTORS=$(expr ${TABLE_SECTORS} + ${FRMW_SECTORS} + ${ROOT_SECTORS})

# Prepare image file
if [ "$ENABLE_SPLITFS" = true ] ; then
  dd if=/dev/zero of="$IMAGE_NAME-frmw.img" bs=512 count=${TABLE_SECTORS}
  dd if=/dev/zero of="$IMAGE_NAME-frmw.img" bs=512 count=0 seek=${FRMW_SECTORS}
  dd if=/dev/zero of="$IMAGE_NAME-root.img" bs=512 count=${TABLE_SECTORS}
  dd if=/dev/zero of="$IMAGE_NAME-root.img" bs=512 count=0 seek=${ROOT_SECTORS}

  # Write firmware/boot partition tables
  sfdisk -q -L -uS -f "$IMAGE_NAME-frmw.img" 2> /dev/null <<EOM
${TABLE_SECTORS},${FRMW_SECTORS},c,*
EOM

  # Write root partition table
  sfdisk -q -L -uS -f "$IMAGE_NAME-root.img" 2> /dev/null <<EOM
${TABLE_SECTORS},${ROOT_SECTORS},83
EOM

  # Setup temporary loop devices
  FRMW_LOOP="$(losetup -o 1M --sizelimit 128M -f --show $IMAGE_NAME-frmw.img)"
  ROOT_LOOP="$(losetup -o 1M -f --show $IMAGE_NAME-root.img)"
else # ENABLE_SPLITFS=false
  dd if=/dev/zero of="$IMAGE_NAME.img" bs=512 count=${TABLE_SECTORS}
  dd if=/dev/zero of="$IMAGE_NAME.img" bs=512 count=0 seek=${IMAGE_SECTORS}

  # Write partition table
  sfdisk -q -L -uS -f "$IMAGE_NAME.img" 2> /dev/null <<EOM
${TABLE_SECTORS},${FRMW_SECTORS},c,*
${ROOT_OFFSET},${ROOT_SECTORS},83
EOM

  # Setup temporary loop devices
  FRMW_LOOP="$(losetup -o 1M --sizelimit 128M -f --show $IMAGE_NAME.img)"
  ROOT_LOOP="$(losetup -o 129M -f --show $IMAGE_NAME.img)"
fi

if [ "$ENABLE_CRYPTFS" = true ] ; then
  # Create dummy ext4 fs
  mkfs.ext4 "$ROOT_LOOP"

  # Setup password keyfile
  touch .password
  chmod 600 .password
  echo -n ${CRYPTFS_PASSWORD} > .password

  # Initialize encrypted partition
  echo "YES" | cryptsetup luksFormat "${ROOT_LOOP}" -c "${CRYPTFS_CIPHER}" -s "${CRYPTFS_XTSKEYSIZE}" .password

  # Open encrypted partition and setup mapping
  cryptsetup luksOpen "${ROOT_LOOP}" -d .password "${CRYPTFS_MAPPING}"

  # Secure delete password keyfile
  shred -zu .password

  # Update temporary loop device
  ROOT_LOOP="/dev/mapper/${CRYPTFS_MAPPING}"

  # Wipe encrypted partition (encryption cipher is used for randomness)
  dd if=/dev/zero of="${ROOT_LOOP}" bs=512 count=$(blockdev --getsz "${ROOT_LOOP}")
fi

# Build filesystems
mkfs.vfat "$FRMW_LOOP"
mkfs.ext4 "$ROOT_LOOP"

# Mount the temporary loop devices
mkdir -p "$BUILDDIR/mount"
mount "$ROOT_LOOP" "$BUILDDIR/mount"

mkdir -p "$BUILDDIR/mount/boot"
mount "$FRMW_LOOP" "$BUILDDIR/mount/boot"

# Copy all files from the chroot to the loop device mount point directory
rsync -a  "${R}/" "$BUILDDIR/mount/"

# Unmount all temporary loop devices and mount points
cleanup

# Create block map file(s) of image(s)
if [ "$ENABLE_SPLITFS" = true ] ; then
  # Create block map files for "bmaptool"
  bmaptool create -o "$IMAGE_NAME-frmw.bmap" "$IMAGE_NAME-frmw.img"
  bmaptool create -o "$IMAGE_NAME-root.bmap" "$IMAGE_NAME-root.img"

  # Image was successfully created
  echo "$IMAGE_NAME-frmw.img ($(expr \( ${TABLE_SECTORS} + ${FRMW_SECTORS} \) \* 512 \/ 1024 \/ 1024)M)" ": successfully created"
  echo "$IMAGE_NAME-root.img ($(expr \( ${TABLE_SECTORS} + ${ROOT_SECTORS} \) \* 512 \/ 1024 \/ 1024)M)" ": successfully created"
  
else
  # Create block map file for "bmaptool"
  bmaptool create -o "$IMAGE_NAME.bmap" "$IMAGE_NAME.img"
  
  # Compressing image
  gzip $IMAGE_NAME.img -c > $IMAGE_NAME.img.gz
  md5sum $IMAGE_NAME.img.gz > $IMAGE_NAME.md5

  # Image was successfully created
  echo "$IMAGE_NAME.img ($(expr \( ${TABLE_SECTORS} + ${FRMW_SECTORS} + ${ROOT_SECTORS} \) \* 512 \/ 1024 \/ 1024)M)" ": successfully created"
  
fi

#~ echo "Do you want format SD Card (y/n) ? "
#~ read  -t 30 reply
#~ echo    # (optional) move to a new line
#~ if [ "$reply" = "y" ]; then
 #~ echo "What your device name ? "
 #~ read device
 #~ sfdisk --delete /dev/"$device"
 #~ partprobe /dev/"$device"
 #~ dd if=$IMAGE_NAME.img of=/dev/"$device" bs=512
  #~ #bmaptool copy --bmap "$IMAGE_NAME.bmap" "$IMAGE_NAME.img" "/dev/$device"
#~ fi
