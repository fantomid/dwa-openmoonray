# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0 

# Install Debian/Ubuntu packages for building MoonRay
# source this script in bash

install_qt=1
install_cuda=1
install_cgroup=1
for i in "$@" 
do
case ${i,,} in
    --noqt|-noqt)
        install_qt=0
    ;;
    --nocuda|-nocuda)
        install_cuda=0
    ;;
    --nocgroup|-nocgroup)
        install_cgroup=0
    ;;
    *)
        echo "Unknown option: $i"
        return 1
    ;;
esac
done


# not required if you are not building with GPU support
# install
if [ $install_cuda -eq 1 ] 
then
    echo "CUDA 12.1 installation, don't install the driver"
    wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run
    sh cuda_12.1.0_530.30.02_linux.run --tmpdir=/opt/MoonRay/tmp
fi

apt-get -y install build-essential git

apt-get -y install libglvnd-dev # 1.6.0-1
if [ $install_cgroup -eq 1 ] 
then
    apt-get -y install libcgroup2 libcgroup-dev # 2.0.2-2
fi

apt-get -y install bison flex wget git python3 python3-dev patch \
               libgif-dev libmng-dev libtiff5-dev libjpeg62-turbo-dev \
               libatomic1 uuid-dev openssl libcurl4-openssl-dev libhwloc-dev \
               libfreetype-dev libssl-dev libjemalloc-dev
               
apt-get -y install python-is-python3 python3-jinja2 python3-pip pyside2-tools python3-numpy qtbase5-dev-tools

mkdir -p /installs/{bin,lib,include}
cd /installs

apt-get -y install cmake # 3.25.1

apt-get -y install libblosc-dev # 1.21.3
apt-get -y install lua5.4 liblua5.4-dev
apt-get -y install liblog4cplus-dev # 2.0.8-1
apt-get -y install libcppunit-dev # 1.15.1-4
apt-get -y install libmicrohttpd-dev # 0.9.75-6

# not required if you are not building the GUI apps
if [ $install_qt -eq 1 ]
then
    apt-get -y install qtbase5-dev qtscript5-dev
fi

if [ $install_cuda -eq 1 ]
then
	export PATH=/usr/local/cuda-12.1/bin:${PATH}
	export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64:${LD_LIBRARY_PATH}
    echo "To complete your CUDA installation, update your ~/.bashrc file with:"
    echo "export PATH=/usr/local/cuda-12.1/bin:${PATH}"
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64:${LD_LIBRARY_PATH}"
fi
