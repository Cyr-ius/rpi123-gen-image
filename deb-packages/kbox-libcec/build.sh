#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh


[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf libcec* *-tmp

#Pull source
URL="https://github.com/raspberrypi/firmware.git"
pull_source "${URL}" "firmware-tmp"

if [ -d firmware-tmp ];then 
	VC_LIB="/home/cyr-ius/rpi123-gen-image/deb-packages/kbox-libcec/firmware-tmp/opt/vc/lib"
	VC_INCLUDE="/home/cyr-ius/rpi123-gen-image/deb-packages/kbox-libcec/firmware-tmp/opt/vc/include"
fi

URL="https://github.com/Pulse-Eight/platform.git"
pull_source "${URL}" "p8-tmp"

URL="https://github.com/Pulse-Eight/libcec.git"
pull_source "${URL}" "files-tmp"

URL="https://git.kernel.org/pub/scm/linux/hotplug/udev.git"
pull_source "${URL}" "udev-tmp"

# Install depends
install_deb "cmake libudev-dev libxrandr-dev python-dev swig gtk-doc-tools libblkid-dev libkmod-dev"

pushd udev-tmp
./autogen.sh
./configure --host=${CROSS_COMPILE} --prefix="/home/cyr-ius/rpi123-gen-image/deb-packages/kbox-libcec/depends" --with-pci-ids-path="/usr/share/hwdata/pci.ids" --disable-introspection --disable-keymap --disable-gudev
make
popd

#  Build package
pushd p8-tmp
cmake -DCMAKE_INSTALL_PREFIX="$(dirname "$0")/../../depends" -DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" -DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip"  .
make
make install
popd

pushd files-tmp
cmake 	-Dp8-platform_DIR="/home/cyr-ius/rpi123-gen-image/deb-packages/kbox-libcec/depends/lib/p8-platform" \
		-DCMAKE_TOOLCHAIN_FILE=cmake/CrossCompile.cmake \
		-DXCOMPILE_PREFIX="${CROSS_COMPILE}-" \
		-DXCOMPILE_BASE_PATH=/usr \
		-DXCOMPILE_LIB_PATH=${VC_LIB} \
		-DRPI_INCLUDE_DIR=${VC_INCLUDE} \
		-DRPI_LIB_DIR=${VC_LIB} \
		-DCMAKE_BUILD_TYPE=Release \
		-DHAVE_EXYNOS_API=0 \
		-DHAVE_RPI_API=1 \
		-DSKIP_PYTHON_WRAPPER:STRING=1 .	
make
dpkg-buildpackage -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv libcec* ../packages

rm -rf *-tmp
popd
