#!/bin/bash
[ ! $1 ] && echo "Architecture not found , please add argument (rbp1 | rbp2 | rbp3)" && exit
pushd $(dirname "$0")
. ../../functions.sh

build_env $1

VERSION="1.3"

rm -rf perftune* *-tmp

# Pull source
URL="https://github.com/cyr-ius/perftune"
pull_source "${URL}" "files-tmp"

#  Build package
pushd files-tmp
fix_version $VERSION
fix_distribution "stretch"
fix_arch $RELEASE_ARCH
dpkg-buildpackage -B -us -uc -a $RELEASE_ARCH
popd

mkdir -p ../../packages
mv perftune*  ../../packages

rm -rf *-tmp
popd
