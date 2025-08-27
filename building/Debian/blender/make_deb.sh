#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ $# -lt 3 ] ; then
    echo "Blender version, moonRay source and install directories are mandatory to create the Debian's package !"
    exit 1
fi

VERSION=$1

if [ ! -d "$3/bin" ]; then
    echo "$3/bin does not exist, can't create the Debian's package."
    exit
fi

if [ ! -d "$3/lib" ]; then
    echo "$3/lib does not exist, can't create the Debian's package."
    exit
fi

if [ ! -d "$3/openmoonray" ]; then
    echo "$3/openmoonray does not exist, can't create the Debian's package."
    exit
fi

if [ ! -d "$2/building/Debian/blender/package" ]; then
    echo "$2/building/Debian/blender/package does not exist, can't create the Debian's package."
    exit
fi

PACKAGE_DIR=$2/building/Debian/blender/package
PACKAGE_CONTROL_DIR=$2/building/Debian/blender/package/moonray/DEBIAN
PACKAGE_NAME="moonray-full-blender-bookworm+cpu-gpu"
PACKAGE_CONTROL_FIELD_PACKAGE="Package: $PACKAGE_NAME"
PACKAGE_CONTROL_FIELD_DEPENDS="Depends: libglvnd0, libcgroup2, libgif7, libmng1, libjpeg62-turbo, libatomic1, libuuid1, openssl, libcurl4, libhwloc15, libfreetype6, libssl3, libjemalloc2, libblosc1, liblog4cplus-2.0.5, libcppunit-1.15-0, libmicrohttpd12, python-is-python3, lua5.4, liblua5.4-0, libqt5opengl5, libnvoptix1"
PACKAGE_CONTROL_FIELD_DESCRIPTION="Description: DreamWorks MoonRay Production Renderer for Blender $VERSION"

cd $PACKAGE_DIR

awk -v valueDescription="$PACKAGE_CONTROL_FIELD_DESCRIPTION" -v valuePackage="$PACKAGE_CONTROL_FIELD_PACKAGE" -v valueDepends="$PACKAGE_CONTROL_FIELD_DEPENDS" -f $2/building/Debian/make_deb.awk < $PACKAGE_DIR/control.tpl > $PACKAGE_CONTROL_DIR/control

mkdir -p moonray/opt/DreamWorksAnimation/{bin,lib,openmoonray,share}
cp -r $3/bin/* moonray/opt/DreamWorksAnimation/bin/
cp -r $3/lib/* moonray/opt/DreamWorksAnimation/lib/
cp -r $3/openmoonray/* moonray/opt/DreamWorksAnimation/openmoonray/
cp -r $3/share/* moonray/opt/DreamWorksAnimation/share/
cp -r $2/testdata moonray/opt/DreamWorksAnimation/

dpkg-deb --build moonray
FILE_NAME="moonray-full-blender_$VERSION-bookworm+cpu-gpu"
VERSION=`dpkg -I moonray.deb | grep Version | cut -d ":" -f 2 | sed 's/ //g'`
ARCH=`dpkg --print-architecture`
mv moonray.deb $3/packages/$FILE_NAME\_$VERSION\_$ARCH.deb

rm -rf moonray/opt

cd -
