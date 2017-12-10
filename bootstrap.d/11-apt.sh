#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Install and setup APT proxy configuration
if [ -z "$APT_PROXY" ] ; then
  install_readonly files/apt/10-proxy "${ETC_DIR}/apt/apt.conf.d"
  sed -i "s/\"\"/\"${APT_PROXY}\"/" "${ETC_DIR}/apt/apt.conf.d/10-proxy"
fi

# Install APT configuration files   
install_readonly files/apt/06-noipv6 "${ETC_DIR}/apt/apt.conf.d"

install_deb "gnupg2"

# Install APT sources.list
install_readonly files/apt/debian.list "${ETC_DIR}/apt/sources.list"

# Install APT raspbian
if [ "$ENABLE_RASPBIAN" = true ] ; then  
  install_readonly files/apt/raspbian.list "${ETC_DIR}/apt/sources.list"
  install_readonly files/apt/raspbian.gpg.key "${ETC_DIR}/apt"
  chroot_exec<<EOF
apt-key add - < /etc/apt/raspbian.gpg.key
EOF
fi

# Install APT raspberry.org
if [ "$ENABLE_RASPBIAN" = true ] ; then  
  install_readonly files/apt/20-raspberrypi-stable "${ETC_DIR}/apt/preferences.d"
  install_readonly files/apt/raspberrypi.list "${ETC_DIR}/apt/sources.list.d"
  install_readonly files/apt/raspberrypi.gpg.key "${ETC_DIR}/apt"
  chroot_exec<<EOF
apt-key add - < /etc/apt/raspberrypi.gpg.key
EOF
fi

# Install APT  ipocus.net
if [ "$ENABLE_IPOCUS" = true ] ; then  
install_readonly files/apt/10-ipocus-stable "${ETC_DIR}/apt/preferences.d"
[ $RPI_MODEL = 0 ] || [ $RPI_MODEL = 1 ] && install_readonly files/apt/ipocus.list.rbp1 "${ETC_DIR}/apt/sources.list.d/ipocus.list"
[ $RPI_MODEL = 2 ] || [ $RPI_MODEL = 3 ] && install_readonly files/apt/ipocus.list.rbp2 "${ETC_DIR}/apt/sources.list.d/ipocus.list"
install_readonly files/apt/ipocus.gpg.key "${ETC_DIR}/apt"
chroot_exec<<EOF
apt-key add - < /etc/apt/ipocus.gpg.key
EOF
fi

# Allow the installation of non-free Debian packages
if [ "$ENABLE_NONFREE" = true ] ; then
  sed -i "s/ contrib/ contrib non-free/" "${ETC_DIR}/apt/sources.list"
fi

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y --allow-unauthenticated -u dist-upgrade

# Install specifics packages
if [ -d packages ] && [ $(ls -A packages) ] ; then
  for package in packages/*.deb ; do
    cp $package ${R}/tmp
    chroot_exec dpkg --unpack /tmp/$(basename $package)
  done
fi
chroot_exec apt-get -qq -y -f install
chroot_exec apt-get -qq -y check

# Install packages from $APT_INCLUDES
touch ${R}/spindle_install
install_deb $APT_INCLUDES
rm -f ${R}/spindle_install
