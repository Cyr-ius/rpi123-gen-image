#
# Setup Splashscreen
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_SPLASHSCREEN" = true ] ; then
  if [ -n "$(search_deb plymouth-theme-kbox-logo)" ]; then 
    install_deb plymouth-theme-kbox-logo 
  else
    mkdir -p "${R}/usr/share/plymouth/themes/kbox"
    install_readonly files/splashscreen/themes/kbox/splash.png "${R}/usr/share/plymouth/themes/kbox/"
    install_readonly files/splashscreen/themes/kbox/kbox.plymouth "${R}/usr/share/plymouth/themes/kbox/"
    install_readonly files/splashscreen/themes/kbox/kbox.script "${R}/usr/share/plymouth/themes/kbox/"
    sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ quiet/"
    sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ splash/"
    sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ plymouth.ignore-serial-consoles/"
    chroot_exec plymouth-set-default-theme -R kbox
  fi
fi
