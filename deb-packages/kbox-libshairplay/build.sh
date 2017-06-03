#!/bin/bash
pushd $(dirname "$0")
. ../../functions.sh

[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
build_env $1

rm -rf libshairplay* *-tmp

#Pull source
URL="https://github.com/juhovh/shairplay.git"
pull_source "${URL}" "files-tmp"

VERSION="0.9.0"

#  Build package
cd files-tmp
./autogen.sh
./configure --host=$CROSS_COMPILE PREFIX=/usr
make
cd ..

cp -r files files-bin-tmp
cp -r files-dev files-dev-tmp

make install -C files-tmp DESTDIR=$(pwd)/files-bin-tmp
make install -C files-tmp DESTDIR=$(pwd)/files-dev-tmp

cd files-bin-tmp
echo "override_dh_usrlocal:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

cd files-dev-tmp
echo "override_dh_usrlocal:" >> debian/rules
echo "override_dh_shlibdeps:" >> debian/rules
fix_version_changelog $VERSION
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
cd ..

mkdir -p ../packages
mv libshairplay* ../packages

rm -rf *-tmp
popd
