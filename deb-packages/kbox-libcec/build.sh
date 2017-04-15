#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh
URL="https://github.com/Pulse-Eight/libcec.git"
rm -rf libcec* *-tmp
install_deb libudev-dev
pull_source "${URL}" "files-tmp"

#  Build package
cd files-tmp
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/CrossCompile.cmake -DXCOMPILE_PREFIX="arm-linux-gnueabihf-" -DXCOMPILE_BASE_PATH=/usr -DXCOMPILE_LIB_PATH=../kbox-userland/firmware/hardfp/opt/vc/lib -DRPI_INCLUDE_DIR=../kbox-userland/firmware/hardfp/opt/vc/include -DRPI_LIB_DIR=../kbox-userland/firmware/hardfp/opt/vc/lib .
make
dpkg-buildpackage -us -uc
cd ..
rm -rf *-tmp
popd
