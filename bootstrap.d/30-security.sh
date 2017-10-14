#
# Setup users and security settings
#

# Load utility functions
. ./functions.sh

# Generate crypt(3) password string
ENCRYPTED_PASSWORD=`mkpasswd -m sha-512 "${PASSWORD}"`
ENCRYPTED_USER_PASSWORD=`mkpasswd -m sha-512 "${USER_PASSWORD}"`

# Setup default user
if [ "$ENABLE_USER" = true ] ; then
  chroot_exec adduser --gecos $USER_NAME --add_extra_groups --disabled-password $USER_NAME
  chroot_exec usermod -a -G sudo -p "${ENCRYPTED_USER_PASSWORD}" $USER_NAME
fi

# Setup root password or not
if [ "$ENABLE_ROOT" = true ] ; then
  chroot_exec usermod -p "${ENCRYPTED_PASSWORD}" root
else
  # Set no root password to disable root login
  chroot_exec usermod -p \'!\' root
fi

# Enable serial console systemd style
if [ "$ENABLE_CONSOLE" = true ] ; then
  chroot_exec systemctl enable serial-getty\@ttyAMA0.service
fi

# Add rights for user
chroot_exec usermod -a -G video $USER_NAME
chroot_exec usermod -a -G input $USER_NAME

# Add profile
install_readonly files/profile/profile "${R}/etc/"

# Add rights for sudoers
mkdir -p "${R}/etc/sudoers.d"
echo "${USER_NAME}     ALL= NOPASSWD: ALL" > "${R}/etc/sudoers.d/no-sudo-password"

# Nice limits change
echo "* - nice -1" > "${ETC_DIR}/security/limits.d/no-limit.conf"

#Add rules for polkit-1
if [ -d "${ETC_DIR}/polkit-1" ]; then
  install_readonly files/polkit-1/10-allow-update.pkla "${ETC_DIR}/polkit-1/localauthority/50-local.d/"
  install_readonly files/polkit-1/20-allow-power.pkla "${ETC_DIR}/polkit-1/localauthority/50-local.d/"
fi

