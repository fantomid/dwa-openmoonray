#!/bin/sh

if [ $# -eq 4 ] ; then
    echo 'Current source directory, build-deps directory and install directory are mandatory !'
    exit 1
fi

if [ ! -d "$3/share/cmake" ]; then
  echo "$3/share/cmake does not exist, create it."
  mkdir -p $3/share/cmake/Modules
fi

if [ ! -d "$3/lib/cmake/TBB" ]; then
  echo "$3/lib/cmake/TBB does not exist, create it."
  mkdir -p $3/lib/cmake/TBB
fi

if [ ! -d "$3/lib/pkgconfig" ]; then
  echo "$3/lib/pkgconfig does not exist, create it."
  mkdir -p $3/lib/pkgconfig
fi

echo "Copy TBB include's files"
cp -r $2/TBB-prefix/src/TBB/include/tbb $3/include/
echo "Copy TBB cmake's files"
cp $1/TBB/cmake/* $3/lib/cmake/TBB/
cp -r $2/TBB-prefix/src/TBB/cmake/* $3/share/cmake/Modules/

echo "Copy TBB pkgconfig's file"
cp $1/TBB/pkgconfig/* $3/lib/pkgconfig/
sed -i "s|INSTALL_ROOT|$3|g" "$3/lib/pkgconfig/tbb.pc"

CC_VERSION=`cc --version | grep "Debian" | cut -d" " -f4`
BUILD_DIR=`ls $2/TBB-prefix/src/TBB/build | grep $CC_VERSION`

echo "Copy TBB $BUILD_DIR lib's files"
cp $2/TBB-prefix/src/TBB/build/$BUILD_DIR/libtbb* $3/lib/
