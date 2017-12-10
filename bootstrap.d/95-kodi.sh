#
# Install Kodi features
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_KODI" = true ] ; then
	if [ "$ENABLE_KODI_AUTOSTART" = true ] ; then
		#Install daemon 
		if [ -n "$(search_deb kodi-autostart)" ]; then
			install_deb kodi-autostart
		else
			[ ! -d "${R}/usr/share/ply-lite" ] && mkdir  -p "${R}/usr/share/ply-lite"
			install_readonly files/kodi/splash_crash.png "${R}/usr/share/ply-lite/"
			install_readonly files/kodi/splash.png "${R}/usr/share/ply-lite/"
			install_exec files/kodi/ply-image "${R}/bin/ply-image"
			install_exec files/kodi/checkmodifier "${R}/sbin/"  
			
			install_exec files/kodi/manual-update "${R}/usr/bin/"
			install_readonly files/kodi/manual-update.service "${R}/lib/systemd/system/"
			install_exec files/kodi/mediacenter "${R}/usr/bin/"
			install_readonly files/kodi/mediacenter.service "${R}/lib/systemd/system/"
		fi
		
		# Disable TTY1 because mediacenter.service start automatically KODI
		chroot_exec systemctl disable getty@tty1.service

	fi

	# Set Advanced Settings for Kodi
	install_readonly files/kodi/advancedsettings.xml "${R}/usr/share/kodi/system/"

	#Create samba cache
	mkdir -p "${R}/var/cache/samba"
	
	# Install splashscreen
	if [ "$ENABLE_SPLASHSCREEN" = true ] && [ "$ENABLE_KODI_SPLASHSCREEN" = true ] ; then
		if [ -n "$(search_deb plymouth-theme-kbox-logo)" ]; then 
			install_deb plymouth-theme-kbox-logo 
		else
			mkdir -p "${R}/usr/share/plymouth/themes/kbox"
			install_readonly files/splashscreen/themes/kbox/splash.png "${R}/usr/share/plymouth/themes/kbox/"
			install_readonly files/splashscreen/themes/kbox/kbox.plymouth "${R}/usr/share/plymouth/themes/kbox/"
			install_readonly files/splashscreen/themes/kbox/kbox.script "${R}/usr/share/plymouth/themes/kbox/"
			chroot_exec plymouth-set-default-theme -R kbox
		fi
	fi	
fi


