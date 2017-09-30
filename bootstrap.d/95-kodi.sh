#
# Install KODI bin and addons
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_KODI" = true ] ; then

	if [ "$ENABLE_KODI_AUTOSTART" = true ] ; then
	
		#Install daemon 
		if [ -n "$(search_deb ply-lite)" ]; then
			install_deb ply-lite
		else
			[ ! -d "${R}/usr/share/ply-lite" ] && mkdir  -p "${R}/usr/share/ply-lite"
			install_readonly files/kodi/splash_sad.png "${R}/usr/share/ply-lite/"
			install_exec files/kodi/ply-image "${R}/bin/ply-image"
		chroot_exec << EOF
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/splash.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/halt.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/reboot.png
ln -s /usr/share/kodi/media/Splash.png /usr/share/ply-lite/poweroff.png 
EOF
		fi

		install_exec files/kodi/manual-update "${R}/usr/bin/"
		install_readonly files/kodi/manual-update.service "${R}/lib/systemd/system/"
		install_exec files/kodi/checkmodifier "${R}/sbin/"  
		install_exec files/kodi/mediacenter "${R}/usr/bin/"
		install_readonly files/kodi/mediacenter.service "${R}/lib/systemd/system/"
	fi
	
	# Disable TTY1 because mediacenter.service start automatically KODI
	chroot_exec systemctl disable getty@tty1.service

	# Set Advanced Settings for Kodi
	install_readonly files/kodi/advancedsettings.xml "${R}/usr/share/kodi/system/"

	#Create samba cache
	mkdir -p "${R}/var/cache/samba"

	#Add polkit and rule
	install_readonly files/etc/polkit-1/localauthority/50-local.d/20-kodi-power.pkla "${ETC_DIR}/polkit-1/localauthority/50-local.d/"
fi
