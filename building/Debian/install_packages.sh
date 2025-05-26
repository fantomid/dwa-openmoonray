VERSION=`cat /etc/debian_version`
read major minor < <(echo $VERSION | ( IFS=".$IFS" ; read a b && echo $a $b ))

if [ $major -eq 12 ] 
then
    ./bookworm/install_packages.sh "$@"
fi