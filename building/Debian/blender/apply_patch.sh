#!/bin/sh

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ $# -eq 4 ] ; then
    echo 'Blender version  and MoonRay source directory are mandatory to apply all the patch !'
    exit 1
fi

blender_version=$1
sources_dir=$2

blender_version_supported=("4.2" "4.5")
if [[ ${blender_version_supported[@]} =~ $blender_version ]]; then
    blender_patch_dir="v$blender_version"
else
    echo "Blender version $blender_version is not supported"
    exit 1
fi

cd $sources_dir/arras/arras_render
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/arras_render.patch

cd $sources_dir/arras/arras4_core
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/arras4_core.patch

cd $sources_dir/cmake_modules
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/cmake_modules.patch

cd $sources_dir/moonray/hydra/hdMoonray
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/hdMoonray.patch

cd $sources_dir/moonray/moonray_arras/mcrt_computation
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/mcrt_computation.patch

cd $sources_dir/moonray/mcrt_denoise
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/mcrt_denoise.patch

cd $sources_dir/moonray/moonray_gui
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/moonray_gui.patch

cd $sources_dir/moonray/hydra/moonray_sdr_plugins
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/moonray_sdr_plugins.patch

cd $sources_dir/moonray/moonray
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/moonray.patch

cd $sources_dir/moonray/moonshine_usd
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/moonshine_usd.patch

cd $sources_dir/moonray/moonshine
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/moonshine.patch

cd $sources_dir/moonray/scene_rdl2
patch -p1 < $sources_dir/building/Debian/blender/patch/$blender_patch_dir/scene_rdl2.patch
