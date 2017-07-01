#
# Setup Logging
#

# Load utility functions
. ./functions.sh

#Locate to syslog
sed -i "s|messages|syslog|g" "${ETC_DIR}/rsyslog.conf"

# Disable rsyslog
if [ "$ENABLE_RSYSLOG" = false ] ; then
  sed -i "s|[#]*ForwardToSyslog=yes|ForwardToSyslog=no|g" "${ETC_DIR}/systemd/journald.conf"
  chroot_exec systemctl disable rsyslog
  chroot_exec apt-get -qq -y purge rsyslog
fi
