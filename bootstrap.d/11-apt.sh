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
install_readonly files/apt/sources.list "${ETC_DIR}/apt/sources.list"

# Use specified APT server and release
sed -i "s/\/ftp.debian.org\//\/${APT_SERVER}\//" "${ETC_DIR}/apt/sources.list"
sed -i "s/ stretch/ ${RELEASE}/" "${ETC_DIR}/apt/sources.list"


# Allow the installation of non-free Debian packages
if [ "$ENABLE_NONFREE" = true ] ; then
  sed -i "s/ contrib/ contrib non-free/" "${ETC_DIR}/apt/sources.list"
fi

# Add Ipocus depot
if [ ! -f "${ETC_DIR}/apt/preferences.d/100ipocus-stable" ]; then
 install_readonly files/apt/package.ipocus.net.asc "${ETC_DIR}/apt/"
 chroot_exec <<EOF
HOME=/root gpg --import /etc/apt/package.ipocus.net.asc /root/.gnupg
HOME=/root gpg -a --export 300BFF2BE9E1998C /root/.gnupg | apt-key add -
EOF
 install_readonly files/apt/100ipocus-stable "${ETC_DIR}/apt/preferences.d/"
fi

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
install_deb $APT_INCLUDES

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y --allow-unauthenticated -u dist-upgrade
