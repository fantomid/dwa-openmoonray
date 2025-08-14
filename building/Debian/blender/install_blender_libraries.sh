#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ $# -eq 4 ] ; then
    echo 'Blender version, build-deps directory and install directory are mandatory !'
    exit 1
fi

blender_version=$1
build_deps_dir=$2
install_dir=$3

blender_version_supported=("4.2" "4.5")
if [[ ${blender_version_supported[@]} =~ $blender_version ]]; then
    blender_version_branch="blender-v$blender_version-release"
else
    echo "Blender version $blender_version is not supported"
    exit 1
fi

echo "Copy libraries of Blender v$blender_version"

cd $build_deps_dir
git clone https://projects.blender.org/blender/lib-linux_x64 Blender_libraries
cd Blender_libraries
git checkout $blender_version_branch
git lfs fetch
git lfs checkout

sources_dir=$2/Blender_libraries

strings=(boost
    dpcpp
    embree
    imath
    jemalloc
    jpeg
    materialx
    opencolorio
    openexr
    openimagedenoise
    openimageio
    openjpeg
    opensubdiv
    openvdb
    png
    python
    tbb
    tiff
    usd
    zlib
)

for i in "${strings[@]}"; do
    if [ $i == "dpcpp" ] 
    then
        cp -r $sources_dir/$i/lib/libsycl.s* $install_dir/lib/
    else
        cp -r $sources_dir/$i/* $install_dir/
    fi
done

# Copy cmake files
if [ ! -d "$install_dir/lib/cmake" ]; then
    mkdir -p $install_dir/lib/cmake
fi
cp $script_dir/cmake/* $install_dir/lib/cmake/
cp $script_dir/cmake/v$blender_version/* $install_dir/lib/cmake/


