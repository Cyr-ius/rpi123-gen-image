#
# Install KODI bin and addons
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_KODI" = true ] ; then
 #Install Kodi
 install_deb kodi kodi-bin kodi-pvr-* kodi-visualization-* kodi-audiodecoder-* kodi-audioencoder-* kodi-inputstream-*
 
 #Install daemon
 install_exec files/kodi/manual-update "${R}/usr/bin/"
 install_readonly files/kodi/manual-update.service "${R}/lib/systemd/system/"
 install_exec files/kodi/mediacenter "${R}/usr/bin/"
 install_readonly files/kodi/mediacenter.service "${R}/lib/systemd/system/"
 install_readonly files/kodi/advancedsettings.xml "${R}/usr/share/kodi/system/"

 # Disable TTY1 because mediacenter.service start automatically KODI
 chroot_exec systemctl disable getty@tty1.service
 
 #Create samba cache
 mkdir -p "${R}/var/cache/samba"
fi
