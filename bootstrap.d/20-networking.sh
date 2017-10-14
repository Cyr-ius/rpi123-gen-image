#
# Setup Networking
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_WIRELESS" = true ]; then
	ETH_IF=wlan
else
	ETH_IF=eth
fi 
# Install and setup hostname
#~ install_readonly files/network/hostname "${ETC_DIR}/hostname"
#~ sed -i "s/^rpi2-jessie/${HOST_NAME}/" "${ETC_DIR}/hostname"
echo "${HOST_NAME}" > "${ETC_DIR}/hostname"

# Install and setup hosts
install_readonly files/network/hosts "${ETC_DIR}/hosts"
sed -i "s/rpi2-jessie/${HOST_NAME}/" "${ETC_DIR}/hosts"

# Setup hostname entry with static IP
if [ "$NET_ADDRESS" != "" ]; then
	NET_IP=$(echo "${NET_ADDRESS}" | cut -f 1 -d'/')
	sed -i "s/^127.0.1.1/${NET_IP}/" "${ETC_DIR}/hosts"
fi

# Remove IPv6 hosts
if [ "$ENABLE_IPV6" = false ]; then
	sed -i -e "/::[1-9]/d" -e "/^$/d" "${ETC_DIR}/hosts"
fi

# Install hint about network configuration
install_readonly files/network/interfaces "${ETC_DIR}/network/interfaces"

# Install configuration for interface eth0
install_readonly files/network/$ETH_IF.network "${ETC_DIR}/systemd/network/$ETH_IF.network"

if [ "$ENABLE_DHCP" = true ]; then
  
	# Enable DHCP configuration for interface eth0
	sed -i -e "s/DHCP=.*/DHCP=yes/" -e "/DHCP/q" "${ETC_DIR}/systemd/network/$ETH_IF.network"
  
	# Set DHCP configuration to IPv4 only
	if [ "$ENABLE_IPV6" = false ]; then
		sed -i "s/DHCP=.*/DHCP=v4/" "${ETC_DIR}/systemd/network/$ETH_IF.network"
	fi

else # ENABLE_DHCP=false
	# Set static network configuration for interface eth0
	sed -i\
	-e "s|DHCP=.*|DHCP=no|"\
	-e "s|Address=\$|Address=${NET_ADDRESS}|"\
	-e "s|Gateway=\$|Gateway=${NET_GATEWAY}|"\
	-e "0,/DNS=\$/ s|DNS=\$|DNS=${NET_DNS_1}|"\
	-e "0,/DNS=\$/ s|DNS=\$|DNS=${NET_DNS_2}|"\
	-e "s|Domains=\$|Domains=${NET_DNS_DOMAINS}|"\
	-e "0,/NTP=\$/ s|NTP=\$|NTP=${NET_NTP_1}|"\
	-e "0,/NTP=\$/ s|NTP=\$|NTP=${NET_NTP_2}|"\
	"${ETC_DIR}/systemd/network/eth.network"
fi

# Remove empty settings from network configuration
sed -i "/.*=\$/d" "${ETC_DIR}/systemd/network/$ETH_IF.network"

# Move systemd network configuration if required by Debian release
if [ "$RELEASE" = "stretch" ]; then
	mv -v "${ETC_DIR}/systemd/network/$ETH_IF.network" "${LIB_DIR}/systemd/network/10-$ETH_IF.network"
	rm -fr "${ETC_DIR}/systemd/network"
fi

# Enable systemd-networkd service
chroot_exec systemctl enable systemd-networkd

# Install host.conf resolver configuration
install_readonly files/network/host.conf "${ETC_DIR}/host.conf"

# Enable network stack hardening
if [ "$ENABLE_HARDNET" = true ] ; then
	# Install sysctl.d configuration files
	install_readonly files/sysctl.d/82-rpi-net-hardening.conf "${ETC_DIR}/sysctl.d/82-rpi-net-hardening.conf"

	# Setup resolver warnings about spoofed addresses
	sed -i "s/^# spoof warn/spoof warn/" "${ETC_DIR}/host.conf"
fi

# Enable time sync
if [ "NET_NTP_1" != "" ] ; then
	chroot_exec systemctl enable systemd-timesyncd.service
fi

#Display Ip address on TTY
echo "${ETH_IF}0: \4{${ETH_IF}0}" >> "${ETC_DIR}/issue"
echo "" >> "${ETC_DIR}/issue"

# Download the firmware binary blob required to use the RPi3 wireless interface
if [ "$ENABLE_WIRELESS" = true ]; then
	# Disable IPv6
	if [ "$ENABLE_IPV6" = false ]; then
		install_readonly files/modprobe.d/ipv6.conf "${ETC_DIR}/modprobe.d/"
	fi

	#Enable wpa_supplicant service
	touch "${ETC_DIR}/wpa_supplicant/wpa_supplicant@wlan0.conf"
	chroot_exec systemctl enable wpa_supplicant@wlan0.service
  
	#Fix firmware binary blob
	if [ -e "${R}/lib/firmware/brcm/brcmfmac43430-sdio.bin" ] && [ ! -e "${R}/lib/firmware/brcm/brcmfmac43430-sdio.txt" ] ; then
		install_readonly files/network/brcmfmac43430-sdio.txt "${R}/lib/firmware/brcm"
	fi
  
	#Disable power managment
	install_readonly files/network/wifi-power-management-off.service "${R}/lib/systemd/system"
	chroot_exec systemctl enable wifi-power-management-off.service
	
	#Copy user wpa_supplicant.conf
	install_readonly files/network/wireless-setting.service "${R}/lib/systemd/system"
	chroot_exec systemctl enable wireless-setting.service	
	
	
fi
  