#!/bin/sh

only_cpu=0
if [ $# -lt 3 ] ; then
    echo "MoonRay source and install directories are mandatory to create the Debian's package !"
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

# We consider that the last argument is --cpu 
if [ $# -eq 4 ] ; then
    PACKAGE_DIR=$1/building/Debian/bookworm/package
    PACKAGE_NAME=moonray
else
    PACKAGE_DIR=$1/building/Debian/bookworm/package-xpu
    PACKAGE_NAME=moonray-xpu
fi 

cd $PACKAGE_DIR

mkdir -p moonray/opt/MoonRay/installs
cp -r $2/* moonray/opt/MoonRay/installs

dpkg-deb --build $PACKAGE_NAME
VERSION=`dpkg -I $PACKAGE_NAME.deb | grep Version | cut -d ":" -f 2 | sed 's/ //g'`
mv $PACKAGE_NAME.deb $PACKAGE_NAME-v$VERSION.deb

rm -rf moonray/opt
