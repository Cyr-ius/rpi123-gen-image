#
# Debootstrap basic system
#

# Load utility functions
. ./functions.sh

VARIANT=""
COMPONENTS="main"
EXCLUDES=""
RELEASE_VARIANT=""

# Use non-free Debian packages if needed
if [ "$ENABLE_NONFREE" = true ] ; then
  COMPONENTS="main,non-free"
fi

# Use minbase bootstrap variant which only includes essential packages
if [ "$ENABLE_MINBASE" = true ] ; then
  VARIANT="--variant=minbase"
  RELEASE_VARIANT="-minbase"
fi

# Exclude packages if required by Debian release
if [ "$RELEASE" = "stretch" ] ; then
  #~ EXCLUDES="--exclude=init,systemd-sysv"
  EXCLUDES="--exclude=init"
fi

if [  ! -d "${BUILDDIR}/chroot-${RELEASE_ARCH}${RELEASE_VARIANT}" ]; then
  
  # Base debootstrap (unpack only)
  if [ ! "$(ls -A ${R})" ] ; then
    http_proxy=${APT_PROXY} debootstrap ${EXCLUDES} --no-check-gpg --arch="${RELEASE_ARCH}" --foreign ${VARIANT} --components="${COMPONENTS}" "${RELEASE}" "${R}" "${APT_SERVER}" 
  fi

  # Copy qemu emulator binary to chroot
  install_exec "${QEMU_BINARY}" "${R}${QEMU_BINARY}"

  # Copy debian-archive-keyring.pgp
  mkdir -p "${R}/usr/share/keyrings"
  install_readonly /usr/share/keyrings/debian-archive-keyring.gpg "${R}/usr/share/keyrings/debian-archive-keyring.gpg"
  install_readonly files/apt/raspberrypi.gpg "${R}/usr/share/keyrings/raspberrypi.gpg"

  # Complete the bootstrapping process
  if [ "$(ls -A ${R}/debootstrap)" ] ; then
    chroot_exec /debootstrap/debootstrap --second-stage
  fi

  # Copy & save
  cp -af "${R}" "${BUILDDIR}/chroot-${RELEASE_ARCH}${RELEASE_VARIANT}"

else

  # Clean & copy chroot reference
  rm -rf "${R}"
  cp -af "${BUILDDIR}/chroot-${RELEASE_ARCH}${RELEASE_VARIANT}" "${R}"
fi

# Mount required filesystems
mount -t proc none "${R}/proc"
mount -t sysfs none "${R}/sys"

# Mount pseudo terminal slave if supported by Debian release
if [ -d "${R}/dev/pts" ] ; then
  mount --bind /dev/pts "${R}/dev/pts"
fi
