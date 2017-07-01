#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

echo $(dirname "$0")
VC_LIB=../../firmware/opt/vc/lib
VC_INCLUDE=../../firmware/opt/vc/include

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf libcec* *-tmp

#Pull source
URL="https://github.com/Pulse-Eight/platform.git"
pull_source "${URL}" "p8-tmp"

URL="https://github.com/Pulse-Eight/libcec.git"
pull_source "${URL}" "files-tmp"

URL="https://git.kernel.org/pub/scm/linux/hotplug/udev.git"
pull_source "${URL}" "udev-tmp"

# Install depends
install_deb cmake libudev-dev libxrandr-dev python-dev swig gtk-doc-tools

#~ pushd udev-tmp
#~ ./autogen.sh
#~ ./configure --host=${CROSS_COMPILE} --prefix=$PREFIX
#~ make
#~ popd
#~ exit

#  Build package
pushd p8-tmp
cmake -DCMAKE_INSTALL_PREFIX="$(dirname "$0")/../depends" -DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" -DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip"  .
make
make install
popd

cd files-tmp
cmake 	-Dp8-platform_DIR="/home/cyr-ius/rpi123-gen-image/deb-packages/kbox-libcec/p8-tmp" \
		-DCMAKE_TOOLCHAIN_FILE=cmake/CrossCompile.cmake \
		-DXCOMPILE_PREFIX="${CROSS_COMPILE}-" \
		-DXCOMPILE_BASE_PATH=/usr \
		-DXCOMPILE_LIB_PATH=${VC_LIB} \
		-DRPI_INCLUDE_DIR=${VC_INCLUDE} \
		-DRPI_LIB_DIR=${VC_LIB} \
		-DBUILD_SHARED_LIBS=1 \
		-DSKIP_PYTHON_WRAPPER:STRING=1 .
make
dpkg-buildpackage -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv libcec* ../packages

rm -rf *-tmp
popd
