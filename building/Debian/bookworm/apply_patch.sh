#!/bin/sh

if [ $# -eq 2 ] ; then
    echo 'MoonRay source directory is mandatory to apply all the patch !'
    exit 1
fi

cd $1/cmake_modules
patch -p1 < $1/building/Debian/bookworm/patch/cmake_modules.patch

cd $1/arras/arras4_core
patch -p1 < $1/building/Debian/bookworm/patch/arras4_core.patch

cd $1/moonray/hydra/hdMoonray
patch -p1 < $1/building/Debian/bookworm/patch/hdMoonray.patch

cd $1/moonray/moonray_arras/mcrt_computation
patch -p1 < $1/building/Debian/bookworm/patch/mcrt_computation.patch

cd $1/moonray/moonray_gui
patch -p1 < $1/building/Debian/bookworm/patch/moonray_gui.patch

cd $1/moonray/moonray
patch -p1 < $1/building/Debian/bookworm/patch/moonray.patch

cd $1/moonray/moonshine
patch -p1 < $1/building/Debian/bookworm/patch/moonshine.patch

cd $1/moonray/scene_rdl2
patch -p1 < $1/building/Debian/bookworm/patch/scene_rdl2.patch
