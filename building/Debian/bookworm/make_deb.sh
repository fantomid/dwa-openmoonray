#!/bin/sh

if [ $# -eq 3 ] ; then
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

cd $1/building/Debian/bookworm/package

mkdir -p moonray/opt/MoonRay/installs
cp -r $2/* moonray/opt/MoonRay/installs

dpkg-deb --build moonray
VERSION=`dpkg -I moonray.deb | grep Version | cut -d ":" -f 2 | sed 's/ //g'`
NAME=`echo moonray-v$VERSION.deb`
mv moonray.deb moonray-v$VERSION.deb

rm -rf moonray/opt
