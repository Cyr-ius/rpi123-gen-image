#
# Customize and fix errors
#

# Load utility functions
. ./functions.sh

#Optimize mem arm for rpi23
if [ ! "$RPI_MODEL"="3x64" ];then
	install_readonly files/customize/libarmmem.so "${R}/usr/lib/"
	install_readonly files/customize/libarmmem.a "${R}/usr/lib/"
fi

# Fix - Error PROTOCOL_V23 = PROTOCOL_TLS in python 2.7.13
install_readonly files/customize/ssl.py "${R}/usr/lib/python2.7/"

# Fix - Error missing symbolic link in python 2.7.13
chroot_exec << EOT
ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
EOT

