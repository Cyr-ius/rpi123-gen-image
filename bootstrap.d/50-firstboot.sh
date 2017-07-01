#
# First boot actions
#

# Load utility functions
. ./functions.sh

display_message() {
 [ "$ENABLE_SPLASHSCREEN" = true ] && echo "plymouth update --status=\"${*}\"" >> "${ETC_DIR}/rc.firstboot" || echo .
}

# Prepare rc.firstboot script
display_message "Please wait, first boot : initialize configuration..."
cat files/firstboot/10-begin.sh > "${ETC_DIR}/rc.firstboot"


# Ensure openssh server host keys are regenerated on first boot
if [ "$ENABLE_SSHD" = true ] ; then
  cat files/firstboot/21-generate-ssh-keys.sh >> "${ETC_DIR}/rc.firstboot"
fi

# Prepare filesystem auto expand
if [ "$EXPANDROOT" = true ] ; then
  if [ "$ENABLE_CRYPTFS" = false ] ; then
    if [ "$ENABLE_INITRAMFS" = false ]; then
      cat files/firstboot/22-expandroot.sh >> "${ETC_DIR}/rc.firstboot"
    fi
  else
    # Regenerate initramfs to remove encrypted root partition auto expand
    cat files/firstboot/23-regenerate-initramfs.sh >> "${ETC_DIR}/rc.firstboot"
  fi
fi

# Ensure that dbus machine-id exists
cat files/firstboot/24-generate-machineid.sh >> "${ETC_DIR}/rc.firstboot"

# Create /etc/resolv.conf symlink
cat files/firstboot/25-create-resolv-symlink.sh >> "${ETC_DIR}/rc.firstboot"

# Configure automatic network interface names
if [ "$ENABLE_IFNAMES" = true ] ; then
  cat files/firstboot/26-config-ifnames.sh >> "${ETC_DIR}/rc.firstboot"
  cat files/firstboot/27-restart-network.sh >> "${ETC_DIR}/rc.firstboot"
fi

# Add package
#~ display_message "Please wait, first boot : loading package..."
#~ cat files/firstboot/28-install-package.sh >> "${ETC_DIR}/rc.firstboot"
#~ chmod +x "${ETC_DIR}/rc.firstboot"

# Enable mediacenter.service if Kodi installed
if [ "$ENABLE_KODI" = true ]; then
display_message "Please wait, first boot : enable mediacenter..."
cat files/firstboot/30-enable-mediacenter.sh >> "${ETC_DIR}/rc.firstboot"
chmod +x "${ETC_DIR}/rc.firstboot"
fi

# Finalize rc.firstboot script
cat files/firstboot/99-finish.sh >> "${ETC_DIR}/rc.firstboot"
chmod +x "${ETC_DIR}/rc.firstboot"
display_message "Please wait, first boot : clean up ..."


# Install default rc.local if it does not exist
if [ ! -f "${ETC_DIR}/rc.local" ] ; then
  install_exec files/etc/rc.local "${ETC_DIR}/rc.local"
fi

# Add rc.firstboot script to rc.local
sed -i '/exit 0/d' "${ETC_DIR}/rc.local"
echo /etc/rc.firstboot >> "${ETC_DIR}/rc.local"
echo exit 0 >> "${ETC_DIR}/rc.local"
