#
# Customize and fix errors
#

# Load utility functions
. ./functions.sh

# Fix - Error PROTOCOL_V23 = PROTOCOL_TLS in python 2.7.13
install_readonly files/customize/ssl.py "${R}/usr/lib/python2.7/"

# Fix - Error missing symbolic link in python 2.7.13
chroot_exec << EOT
ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
EOT

if [ -n "$(search_deb perftune)" ]; then
	install_deb perftune
fi
