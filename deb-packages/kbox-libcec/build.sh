#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp | rbp2 | rbp3)" && exit
build_env $1

rm -rf libcec* *-tmp

#Pull source
URL="https://github.com/Pulse-Eight/libcec.git"
pull_source "${URL}" "files-tmp"

URL="https://github.com/Pulse-Eight/libcec-support.git"
pull_source "${URL}" "support-tmp"

# Install depends
install_deb libudev-dev libxrandr-dev python-dev swig

#  Build package
cd files-tmp
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/CrossCompile.cmake -DXCOMPILE_PREFIX="${CROSS_COMPILE}-" -DXCOMPILE_BASE_PATH=/usr -DXCOMPILE_LIB_PATH=../kbox-userland/firmware/hardfp/opt/vc/lib -DRPI_INCLUDE_DIR=../kbox-userland/firmware/hardfp/opt/vc/include -DRPI_LIB_DIR=../kbox-userland/firmware/hardfp/opt/vc/lib -DBUILD_SHARED_LIBS=1 .
make
dpkg-buildpackage -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv libcec* ../packages

rm -rf *-tmp
popd
