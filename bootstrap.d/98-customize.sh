#
# Customize and fix errors
#

# Load utility functions
. ./functions.sh

# Fix - Error missing symbolic link in python 2.7
if [ -d "${R}/usr/lib/python2.7/" ]; then
chroot_exec << EOT
ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
EOT
fi

if [ -n "$(search_deb perftune)" ]; then
	install_deb perftune
fi
