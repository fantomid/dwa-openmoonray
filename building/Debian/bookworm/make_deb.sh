#!/bin/bash

if [ $# -lt 3 ] ; then
    echo "MoonRay source, install directories and package's type are mandatory to create the Debian's package !"
    exit 1
fi

if [ ! -d "$2/bin" ]; then
    echo "$2/bin does not exist, can't create the Debian's package."
    exit 1
fi

if [ ! -d "$2/lib" ]; then
    echo "$2/lib does not exist, can't create the Debian's package."
    exit 1
fi

if [ ! -d "$2/openmoonray" ]; then
    echo "$2/openmoonray does not exist, can't create the Debian's package."
    exit 1
fi

PACKAGE_DIR=$1/building/Debian/bookworm/package
PACKAGE_CONTROL_DIR=$1/building/Debian/bookworm/package/moonray/DEBIAN
if [ $3 = "cpu" ]; then
    PACKAGE_NAME="moonray-full-bookworm+cpu-only"
    PACKAGE_CONTROL_FIELD_PACKAGE="Package: $PACKAGE_NAME"
    PACKAGE_CONTROL_FIELD_DEPENDS="Depends: libglvnd0, libcgroup2, libgif7, libmng1, libjpeg62-turbo, libatomic1, libuuid1, openssl, libcurl4, libhwloc15, libfreetype6, libssl3, libjemalloc2, libblosc1, liblog4cplus-2.0.5, libcppunit-1.15-0, libmicrohttpd12, python-is-python3, lua5.4, liblua5.4-0, libqt5opengl5"
elif [ $3 = "xpu" ]; then
    PACKAGE_NAME="moonray-full-bookworm+cpu-gpu"
    PACKAGE_CONTROL_FIELD_PACKAGE="Package: $PACKAGE_NAME"
    PACKAGE_CONTROL_FIELD_DEPENDS="Depends: libglvnd0, libcgroup2, libgif7, libmng1, libjpeg62-turbo, libatomic1, libuuid1, openssl, libcurl4, libhwloc15, libfreetype6, libssl3, libjemalloc2, libblosc1, liblog4cplus-2.0.5, libcppunit-1.15-0, libmicrohttpd12, python-is-python3, lua5.4, liblua5.4-0, libqt5opengl5, libnvoptix1"
else
    echo "$3 is invalid, package's type could be cpu or xpu, can't create the Debian's package."
    exit 1
fi

cd $PACKAGE_DIR
awk -v valuePackage="$PACKAGE_CONTROL_FIELD_PACKAGE" -v valueDepends="$PACKAGE_CONTROL_FIELD_DEPENDS" -f $1/building/Debian/make_deb.awk < $PACKAGE_DIR/control.tpl > $PACKAGE_CONTROL_DIR/control

mkdir -p moonray/opt/MoonRay/installs
cp -r $2/* moonray/opt/MoonRay/installs
cp -r $1/testdata moonray/opt/MoonRay/installs/

dpkg-deb --build moonray
VERSION=`dpkg -I moonray.deb | grep Version | cut -d ":" -f 2 | sed 's/ //g'`
ARCH=`dpkg --print-architecture`
mv moonray.deb $2/$PACKAGE_NAME\_$VERSION\_$ARCH.deb

rm -rf moonray/opt

cd -
