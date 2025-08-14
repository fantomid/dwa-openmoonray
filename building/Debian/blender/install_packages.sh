# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0 

# Install Debian/Ubuntu packages for building MoonRay for Blender
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
    --nocgroup|-nocgroup)
        install_cgroup=0
    ;;
    *)
        echo "Unknown option: $i"
        return 1
    ;;
esac
done

export PATH=$PATH:/sbin

apt-get -y install build-essential git git-lfs wget

if [ $install_cuda -eq 1 ] 
then
    echo "CUDA 12.1 installation, don't install the driver"
    wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run
    sh cuda_12.1.0_530.30.02_linux.run --tmpdir=/opt/DreamWorksAnimation/tmp_dirs/tmp
fi

if [ $install_cgroup -eq 1 ] 
then
    apt-get -y install libcgroup2 libcgroup-dev # 2.0.2-2
fi

apt-get -y install bison flex patch \
	libatomic1 uuid-dev openssl libcurl4-openssl-dev libhwloc-dev \
	libfreetype-dev libssl-dev
               
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
