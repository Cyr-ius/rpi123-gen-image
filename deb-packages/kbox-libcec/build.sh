#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh


[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

#~ rm -rf libcec* *-tmp

#Pull source
URL="https://github.com/raspberrypi/firmware.git"
pull_source "${URL}" "firmware-tmp"

if [ -d firmware-tmp ];then 
	VC_LIB="/media/multimedia/rpi123-gen-image/deb-packages/kbox-libcec/firmware-tmp/hardfp/opt/vc/lib"
	VC_INCLUDE="/media/multimedia/rpi123-gen-image/deb-packages/kbox-libcec/firmware-tmp/hardfp/opt/vc/include"
fi

#~ URL="https://github.com/Pulse-Eight/platform.git"
#~ pull_source "${URL}" "p8-tmp"

URL="https://github.com/Pulse-Eight/libcec.git"
pull_source "${URL}" "files-tmp"

#~ URL="https://git.kernel.org/pub/scm/linux/hotplug/udev.git"
#~ pull_source "${URL}" "udev-tmp"

# Install depends
install_deb "cmake libudev libudev-dev libxrandr-dev python-dev swig gtk-doc-tools libblkid-dev libkmod-dev"

#~ pushd udev-tmp
#~ ./autogen.sh
#~ ./configure --host=${CROSS_COMPILE} --prefix="/media/multimedia/rpi123-gen-image/deb-packages/kbox-libcec/depends" --with-pci-ids-path="/usr/share/hwdata/pci.ids" --disable-introspection --disable-keymap --disable-gudev
#~ make
#~ make install
#~ popd

#  Build package
#~ pushd p8-tmp
#~ cmake -DCMAKE_INSTALL_PREFIX="$(dirname "$0")/../../depends" -DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" -DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip"  .
#~ make
#~ make install
#~ popd
#~ CROSS_COMPILE="../../media/multimedia/rpi123-gen-image/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf"
#~ PATH=/media/multimedia/rpi123-gen-image/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:$PATH
pushd files-tmp
patch -p1 -i ../remove_git_info.patch
cmake 	-DCMAKE_TOOLCHAIN_FILE=cmake/CrossCompile.cmake \
		-DXCOMPILE_PREFIX="${CROSS_COMPILE}-" \
		-DXCOMPILE_LIB_PATH=${VC_LIB} \
		-DXCOMPILE_BASE_PATH=/usr \
		-DRPI_INCLUDE_DIR=${VC_INCLUDE} \
		-DRPI_LIB_DIR=${VC_LIB} \
		-DCMAKE_INSTALL_LIBDIR=/lib \
		-DBUILD_SHARED_LIBS=1 \
		-DSKIP_PYTHON_WRAPPER:STRING=1 .
make
dpkg-buildpackage -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv libcec* ../packages

#~ rm -rf *-tmp
popd
