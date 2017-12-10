#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

CURRENT_PATH=$(pwd)
CROSS_COMPILE=${CURRENT_PATH}/../../tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf
export PKG_CONFIG_LIBDIR=${CURRENT_PATH}/lib/pkgconfig
export LDFLAGS="-L${CURRENT_PATH}/files-tmp/lib -L${CURRENT_PATH}/firmware-tmp/hardfp/opt/vc/lib -lEGL -lGLESv2 -lbcm_host -lvcos -lvchiq_arm"
export CFLAGS="-I${CURRENT_PATH}/files-tmp/include -I${CURRENT_PATH}/firmware-tmp/hardfp/opt/vc/include"
# Intégrer des library LDFLAGS pour make ou valoriser CMAKE_C_FLAGS pour cmake
# Intégrer des INCLUDE , il faut passer la variable CFLAGS pour make ou valoriser CMAKE_CXX__FLAGS pour cmake

#Download firmware

rm -rf *cec* *-tmp

URL="https://github.com/raspberrypi/firmware.git"
pull_source "${URL}" "firmware-tmp"

if [ -d firmware-tmp ];then 
	VC_LIB="${CURRENT_PATH}/firmware-tmp/hardfp/opt/vc/lib"
	VC_INCLUDE="${CURRENT_PATH}/firmware-tmp/hardfp/opt/vc/include"
fi

#Download p8-platform
URL="https://github.com/Pulse-Eight/platform.git"
pull_source "${URL}" "p8-tmp"


#Download libcec
URL="https://github.com/Pulse-Eight/libcec.git"
pull_source "${URL}" "files-tmp"

# Install depends
#~ install_deb apt install cmake libudev libudev-dev libxrandr-dev python-dev swig gtk-doc-tools libblkid-dev libkmod-dev

#  Build package
pushd p8-tmp
cmake 	-DCMAKE_INSTALL_PREFIX=/ \
		-DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" \
		-DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" \
		-DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip"  .
make -j4
make install DESTDIR="${CURRENT_PATH}/files-tmp"
popd

pushd files-tmp
patch -p1 -i ../patchs/remove_git_info.patch
mkdir -p build
cd build
cmake	\
		-DRPI_INCLUDE_DIR=${VC_INCLUDE} \
		-DRPI_LIB_DIR=${VC_LIB} \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DBUILD_SHARED_LIBS=1 \
		-DCMAKE_C_COMPILER="${CROSS_COMPILE}-gcc" \
		-DCMAKE_CXX_COMPILER="${CROSS_COMPILE}-g++" \
		-DCMAKE_STRIP="/usr/bin/${CROSS_COMPILE}-strip" \
		-DSKIP_PYTHON_WRAPPER:STRING=1  ..

make -j4
make install DESTDIR="${CURRENT_PATH}/files-tmp"
cd ..
echo "override_dh_shlibdeps:" >> debian/rules
sed "s/#DIST#/stretch/g" debian/changelog.in > debian/changelog
sed "s/~stretch//g" -i debian/changelog
sed "/CMAKE/d" -i debian/rules
sed '51,60d' -i debian/control
dpkg-buildpackage -d -B -us -uc -a$RELEASE_ARCH
cd ..

mkdir -p ../../packages
mv *cec* ../../packages

rm -rf *-tmp
popd
