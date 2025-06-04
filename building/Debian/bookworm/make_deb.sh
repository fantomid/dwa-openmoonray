#!/bin/sh

if [ $# -lt 3 ] ; then
    echo "MoonRay source, install directories and package's type are mandatory to create the Debian's package !"
    exit 1
fi

if [ ! -d "$2/bin" ]; then
    echo "$2/bin does not exist, can't create the Debian's package."
    exit
fi

if [ ! -d "$2/lib" ]; then
    echo "$2/lib does not exist, can't create the Debian's package."
    exit
fi

if [ ! -d "$2/openmoonray" ]; then
    echo "$2/openmoonray does not exist, can't create the Debian's package."
    exit
fi

if [ $3 = "cpu"]; then
    PACKAGE_DIR=$1/building/Debian/bookworm/package
    PACKAGE_NAME=moonray
elif [ $3 = "xpu"]; then
    PACKAGE_DIR=$1/building/Debian/bookworm/package-xpu
    PACKAGE_NAME=moonray-xpu
else
    echo "$3 is invalid, package's type could be cpu or xpu, can't create the Debian's package."
    exit
fi

cd $PACKAGE_DIR

mkdir -p moonray/opt/MoonRay/installs
cp -r $2/* moonray/opt/MoonRay/installs

dpkg-deb --build $PACKAGE_NAME
VERSION=`dpkg -I $PACKAGE_NAME.deb | grep Version | cut -d ":" -f 2 | sed 's/ //g'`
ARCH=`dpkg --print-architecture`
mv $PACKAGE_NAME.deb $PACKAGE_NAME\_$VERSION\_$ARCH.deb

rm -rf moonray/opt

cd -
