#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Install and setup APT proxy configuration
if [ -z "$APT_PROXY" ] ; then
  install_readonly files/apt/10proxy "${ETC_DIR}/apt/apt.conf.d/10proxy"
  sed -i "s/\"\"/\"${APT_PROXY}\"/" "${ETC_DIR}/apt/apt.conf.d/10proxy"
fi

# Install APT sources.list
install_readonly files/apt/debian-sources.list "${ETC_DIR}/apt/sources.list"
if [ "$ENABLE_RASPBIAN" = true ] ; then  install_readonly files/apt/raspbian-sources.list "${ETC_DIR}/apt/sources.list";fi


# Use specified APT server and release
sed -i "s|APT_SERVER|${APT_SERVER}|" "${ETC_DIR}/apt/sources.list"
sed -i "s/RELEASE/${RELEASE}/" "${ETC_DIR}/apt/sources.list"


# Allow the installation of non-free Debian packages
if [ "$ENABLE_NONFREE" = true ] ; then
  sed -i "s/ contrib/ contrib non-free/" "${ETC_DIR}/apt/sources.list"
fi

# Upgrade package index
chroot_exec apt-get -qq -y update

if [ -n "$(search_deb gnupg2)" ];then install_deb gnupg2; fi

# Install APT raspberry.org
if [ "$ENABLE_RASPBIAN" = true ] ; then  
  install_readonly files/apt/20raspberrypi-stable "${ETC_DIR}/apt/preferences.d/"
  install_readonly files/apt/raspberrypi.list "${ETC_DIR}/apt/sources.list.d"
  install_readonly files/apt/raspberrypi.gpg.key "${ETC_DIR}/apt/"
  chroot_exec<<EOF
apt-key add - < /etc/apt/raspberrypi.gpg.key
EOF
fi

# Install APT  ipocus.net
install_readonly files/apt/10ipocus-stable "${ETC_DIR}/apt/preferences.d/"
install_readonly files/apt/ipocus.list "${ETC_DIR}/apt/sources.list.d/"
install_readonly files/apt/ipocus.gpg.key "${ETC_DIR}/apt/"
chroot_exec<<EOF
apt-key add - < /etc/apt/ipocus.gpg.key
EOF

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y --allow-unauthenticated -u dist-upgrade

# Install specifics packages
if [ -d packages ] ; then
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
