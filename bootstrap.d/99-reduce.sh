#
# Reduce system disk usage
#

# Load utility functions
. ./functions.sh

# Reduce the image size by various operations
if [ "$ENABLE_REDUCE" = true ] ; then
  if [ "$REDUCE_APT" = true ] ; then
    # Install dpkg configuration file
    if [ "$REDUCE_DOC" = true ] || [ "$REDUCE_MAN" = true ] ; then
      install_readonly files/dpkg/01nodoc "${ETC_DIR}/dpkg/dpkg.cfg.d/01nodoc"
    fi

    # Install APT configuration files   
    install_readonly files/apt/02-nocache "${ETC_DIR}/apt/apt.conf.d"
    install_readonly files/apt/03-compress "${ETC_DIR}/apt/apt.conf.d"
    install_readonly files/apt/04-norecommends "${ETC_DIR}/apt/apt.conf.d"
    install_readonly files/apt/05-nokeepdownload "${ETC_DIR}/apt/apt.conf.d"

    # Remove APT cache files
    rm -fr "${R}/var/cache/apt/pkgcache.bin"
    rm -fr "${R}/var/cache/apt/srcpkgcache.bin"
  fi

  # Remove all doc files
  if [ "$REDUCE_DOC" = true ] ; then
    find "${R}/usr/share/doc" -depth -type f ! -name copyright | xargs rm || true
    find "${R}/usr/share/doc" -empty | xargs rmdir || true
  fi

  # Remove all man pages and info files
  if [ "$REDUCE_MAN" = true ] ; then
    rm -rf "${R}/usr/share/man" "${R}/usr/share/groff" "${R}/usr/share/info" "${R}/usr/share/lintian" "${R}/usr/share/linda" "${R}/var/cache/man"
  fi

  # Remove all locale translation files
  if [ "$REDUCE_LOCALE" = true ] ; then
    find "${R}/usr/share/locale" -mindepth 1 -maxdepth 1 ! -name 'en' | xargs rm -r
  fi

  # Remove hwdb PCI device classes (experimental)
  if [ "$REDUCE_HWDB" = true ] ; then
    rm -fr "/lib/udev/hwdb.d/20-pci-*"
  fi

  # Replace bash shell by dash shell (experimental)
  if [ "$REDUCE_BASH" = true ] ; then
    if [ "$RELEASE" = "stretch" ] ; then
      echo "Yes, do as I say!" | chroot_exec apt-get purge -qq -y --allow-remove-essential bash
    else
      echo "Yes, do as I say!" | chroot_exec apt-get purge -qq -y --force-yes bash
    fi

    chroot_exec update-alternatives --install /bin/bash bash /bin/dash 100
  fi

  # Remove sound utils and libraries
  if [ "$ENABLE_SOUND" = false ] ; then
    chroot_exec apt-get -qq -y purge alsa-utils libsamplerate0 libasound2 libasound2-data
  fi

  # Re-install tools for managing kernel modules
  if [ "$RELEASE" = "jessie" ] ; then
    chroot_exec apt-get -qq -y install module-init-tools
  fi

  # Remove GPU kernels
  if [ "$ENABLE_MINGPU" = true ] ; then
    rm -f "${BOOT_DIR}/start.elf"
    rm -f "${BOOT_DIR}/fixup.dat"
    rm -f "${BOOT_DIR}/start_x.elf"
    rm -f "${BOOT_DIR}/fixup_x.dat"
  fi

  # Clean APT list of repositories
  rm -fr "${R}/var/lib/apt/lists/*"
  chroot_exec apt-get -qq -y update
fi
