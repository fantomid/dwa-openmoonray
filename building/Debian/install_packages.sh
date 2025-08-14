#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
version=`cat /etc/debian_version`
read major minor < <(echo $version | ( IFS=".$IFS" ; read a b && echo $a $b ))

if [ $major -eq 12 ]; then
    exec $script_dir/bookworm/install_packages.sh "$@"
    echo "Packages installed for Debian Bookworm
fi
