#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Fetch and build U-Boot bootloader
if [ "$ENABLE_SPLASHSCREEN" = true ] ; then

 #Install Splashscreen
 [ ! -d "${R}/usr/share/ply-lite" ] && mkdir  -p "${R}/usr/share/ply-lite"
 install_readonly files/splashscreen/splash_sad.png "${R}/usr/share/ply-lite/"
 install_exec files/splashscreen/splash_early "${R}/sbin/"
 install_exec files/splashscreen/ply-image "${R}/bin/ply-image"
 install_exec files/splashscreen/checkmodifier "${R}/sbin/"
 install_readonly files/splashscreen/ply-lite-start.service "${R}/lib/systemd/system/"
 install_readonly files/splashscreen/ply-lite-halt.service "${R}/lib/systemd/system/"
 install_readonly files/splashscreen/ply-lite-reboot.service "${R}/lib/systemd/system/"
 install_readonly files/splashscreen/ply-lite-poweroff.service "${R}/lib/systemd/system/"
 
 # Install plymouth's theme
 install_deb plymouth plymouth-themes
 mkdir -p "${R}/usr/share/plymouth/themes/kodibox"
 install_readonly files/splashscreen/themes/kodibox/Splash.png "${R}/usr/share/plymouth/themes/kodibox/"
 install_readonly files/splashscreen/themes/kodibox/kodibox.plymouth "${R}/usr/share/plymouth/themes/kodibox/"
 install_readonly files/splashscreen/themes/kodibox/kodibox.script "${R}/usr/share/plymouth/themes/kodibox/"
 sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ splash/"
 sed -i "${BOOT_DIR}/cmdline.txt" -e "s/$/ plymouth.ignore-serial-consoles/"

chroot_exec << EOF
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/splash.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/halt.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/reboot.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/poweroff.png
plymouth-set-default-theme -R kodibox
EOF

fi
