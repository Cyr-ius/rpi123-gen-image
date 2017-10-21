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
			install_readonly files/kodi/splash_crash.png "${R}/usr/share/ply-lite/"
			install_readonly files/kodi/splash.png "${R}/usr/share/ply-lite/"
			install_exec files/kodi/ply-image "${R}/bin/ply-image"
			install_exec files/kodi/checkmodifier "${R}/sbin/"  
		fi
		install_exec files/kodi/manual-update "${R}/usr/bin/"
		install_readonly files/kodi/manual-update.service "${R}/lib/systemd/system/"
		install_exec files/kodi/mediacenter "${R}/usr/bin/"
		install_readonly files/kodi/mediacenter.service "${R}/lib/systemd/system/"
	fi
	
	# Disable TTY1 because mediacenter.service start automatically KODI
	chroot_exec systemctl disable getty@tty1.service

	# Set Advanced Settings for Kodi
	install_readonly files/kodi/advancedsettings.xml "${R}/usr/share/kodi/system/"

	#Create samba cache
	mkdir -p "${R}/var/cache/samba"
fi
