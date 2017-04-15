#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Fetch and build U-Boot bootloader
if [ "$ENABLE_SPLASHSCREEN" = true ] ; then
 
 # Install plymouth's theme
 install_deb plymouth plymouth-themes
 
 #Install Splashscreen KBOX
 mkdir -p "${R}/usr/share/plymouth/themes/kbox"
 install_readonly files/splashscreen/themes/kbox/Splash.png "${R}/usr/share/plymouth/themes/kbox/"
 install_readonly files/splashscreen/themes/kbox/kbox.plymouth "${R}/usr/share/plymouth/themes/kbox/"
 install_readonly files/splashscreen/themes/kbox/kbox.script "${R}/usr/share/plymouth/themes/kbox/"
 sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ splash/"
 sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ plymouth.ignore-serial-consoles/"
 chroot_exec plymouth-set-default-theme -R kbox

fi
