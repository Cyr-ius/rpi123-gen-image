# This file contains utility functions used by rpi23-gen-image.sh

cleanup (){
  set +x
  set +e

  # Identify and kill all processes still using files
  echo "killing processes using mount point ..."
  fuser -k "${R}"
  sleep 3
  fuser -9 -k -v "${R}"

  # Clean up temporary .password file
  if [ -r ".password" ] ; then
    shred -zu .password
  fi

  # Clean up all temporary mount points
  echo "removing temporary mount points ..."
  umount -l "${R}/proc" 2> /dev/null
  umount -l "${R}/sys" 2> /dev/null
  umount -l "${R}/dev/pts" 2> /dev/null
  umount "$BUILDDIR/mount/boot" 2> /dev/null
  umount "$BUILDDIR/mount" 2> /dev/null
  cryptsetup close "${CRYPTFS_MAPPING}" 2> /dev/null
  losetup -d "$ROOT_LOOP" 2> /dev/null
  losetup -d "$FRMW_LOOP" 2> /dev/null
  trap - 0 1 2 3 6
}

install_readonly() {
  # Install file with user read-only permissions
  install -o root -g root -m 644 $*
}

install_exec() {
  # Install file with root exec permissions
  install -o root -g root -m 744 $*
}

use_template () {
  # Test if configuration template file exists
  if [ ! -r "./templates/${CONFIG_TEMPLATE}" ] ; then
    echo "error: configuration template ${CONFIG_TEMPLATE} not found"
    exit 1
  fi

  # Load template configuration parameters
  . "./templates/${CONFIG_TEMPLATE}"
}

chroot_exec() {
  # Copy qemu emulator binary to chroot
  [ ! -f "${R}${QEMU_BINARY}" ] && install_exec "${QEMU_BINARY}" "${R}${QEMU_BINARY}"
  
  # Exec command in chroot
  LANG=C LC_ALL=C DEBIAN_FRONTEND=noninteractive chroot ${R} $*
}

chroot_install_cc() {
  # Install c/c++ build environment inside the chroot
  if [ -z "${COMPILER_PACKAGES}" ] ; then
    COMPILER_PACKAGES=$(chroot_exec apt-get -s install g++ make bc | grep "^Inst " | awk -v ORS=" " '{ print $2 }')

    if [ "$RELEASE" = "jessie" ] ; then
      chroot_exec apt-get -q -y --no-install-recommends install ${COMPILER_PACKAGES}
    elif [ "$RELEASE" = "stretch" ] ; then
      chroot_exec apt-get -q -y --allow-unauthenticated --no-install-recommends install ${COMPILER_PACKAGES}
    fi
  fi
}

chroot_remove_cc() {
  # Remove c/c++ build environment from the chroot
  if [ ! -z "${COMPILER_PACKAGES}" ] ; then
    chroot_exec apt-get -qq -y --auto-remove purge ${COMPILER_PACKAGES}
    COMPILER_PACKAGES=""
  fi
}
install_deb() {
  # Install debian packages
  chroot_exec apt-get -q -y --allow-unauthenticated --no-install-recommends install $*
}
fix_version() {
	[ -n $1 ] && CONTROL=$1 || CONTROL="files/DEBIAN/control"
	sed '/Version/d' -i $CONTROL
	echo "Version: $2" >> $CONTROL
}
dpkg_build() {
	# Calculate package size and update control file before packaging.
	if [ ! -e "$1" -o ! -e "$1/DEBIAN/control" ]; then exit 1; fi
	sed '/^Installed-Size/d' -i "$1/DEBIAN/control"
	size=$(du -s --apparent-size "$1" | awk '{print $1}')
	echo "Installed-Size: $size" >> "$1/DEBIAN/control"
	dpkg -b "$1" "$2"
}
pull_source() {
	if [[ $1 =~ \.zip$ ]];	then
          echo -e "Detected ZIP source"
          rm -rf ${2}
          if [ "$2" != "." ]; then mkdir -p ${2}; fi
          wget ${1} -O source.zip
          if [ $? != 0 ]; then echo "Downloading zip failed" && exit 1; fi
          unzip source.zip -d ${2}
          rm source.zip
          return
	fi

	if [[ $1 =~ \.tar$ || $1 =~ \.tgz$ || $1 =~ \.tar\.gz$ || $1 =~ \.tar\.bz2$ || $1 =~ \.tar\.xz$ ]];	then
          echo -e "Detected tarball source"
          rm -rf ${2}
          if [ "$2" != "." ]; then mkdir -p ${2}; fi
          wget ${1} -O source.tar
          if [ $? != 0 ]; then echo "Downloading tarball failed" && exit 1; fi
          tar -xvf source.tar -C ${2}
          rm source.tar
          return
	fi

	if [[ $1 =~ svn ]]; then
          echo -e "Detected SVN source"
          rm -rf ${2}
          svn co ${1} ${2}
          if [ $? != 0 ]; then echo "Source checkout failed" && exit 1; fi
          return
	fi

	if [[ $1 =~ git ]]; then
          echo -e "Detected Git source"
          if [[ "$3" =~ "clean" ]]; then rm -rf ${2};fi
          git clone  ${1} ${2} --depth 1 || if [ $RESET = false ];then return; fi
          pushd ${2}
          git clean -xfd ; git checkout -- * ; git pull ;
          popd
          if [ $? != 0 ]; then echo "Source checkout failed" && exit 1; fi
          return
	fi

	echo -e "No file type match found for URL" && exit 1
}