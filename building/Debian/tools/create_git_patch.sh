#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ ! $# -eq 1 ] ; then
    echo 'MoonRay source directory is mandatory !'
    exit 1
fi

submodules_directory=("arras/arras4_core"
    "arras/arras_render"
    "arras/distributed/minicoord"
    "arras/distributed/arras4_node"
    "cmake_modules"
    "moonray/scene_rdl2"
    "moonray/mcrt_denoise"
    "moonray/moonray"
    "moonray/moonshine"
    "moonray/moonshine_usd"
    "moonray/moonray_arras/mcrt_dataio"
    "moonray/moonray_arras/mcrt_computation"
    "moonray/moonray_arras/mcrt_messages"
    "moonray/moonray_gui"
    "moonray/hydra/hdMoonray"
    "moonray/hydra/moonray_sdr_plugins"
    "moonray/moonray_dcc_plugins"
    "moonray/render_profile_viewer"
    "rats"
)

sources_dir=$1

echo "$sources_dir"
if [ ! -d "$script_dir/result" ]; then
    mkdir $script_dir/result
fi

for i in "${submodules_directory[@]}"; do
    echo "cd to $sources_dir/$i"
    if [ -d $sources_dir/$i ]; then
        patch_filename="${i##*/}"
        cd $sources_dir/$i
        git diff > $script_dir/result/$patch_filename.patch
    fi
done

