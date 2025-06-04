SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
VERSION=`cat /etc/debian_version`
read major minor < <(echo $VERSION | ( IFS=".$IFS" ; read a b && echo $a $b ))

if [ $# -lt 2 ] ; then
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


IS_GPU=`nm -C $2/openmoonray/lib/librendering_rt.so | grep 'moonray::rt::OptixGPUInstance::OptixGPUInstance' | wc -l`

if [ $major -eq 12 ] 
then
    if [ $IS_GPU -eq 0 ]
    then
        exec $SCRIPT_DIR/bookworm/make_deb.sh "$@" "cpu"
    else
        exec $SCRIPT_DIR/bookworm/make_deb.sh "$@" "xpu"
    fi
fi
