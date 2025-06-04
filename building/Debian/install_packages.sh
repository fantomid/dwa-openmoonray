SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
VERSION=`cat /etc/debian_version`
read major minor < <(echo $VERSION | ( IFS=".$IFS" ; read a b && echo $a $b ))

if [ $major -eq 12 ] 
then
    exec $SCRIPT_DIR/bookworm/install_packages.sh "$@"
fi
