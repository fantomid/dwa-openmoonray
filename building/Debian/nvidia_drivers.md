Note 1: Root privileges are required to install the NVIDIA drivers.

Note 2: On recent Debian's distributions, the `sbin` directory is not present in the PATH environment variable. You may have to update your `.bashrc` file or update the environment variable before launching the commands. 

---
## Step 1. Create file to disable the nouveau driver 
---

Open a terminal create the file /etc/modprobe.d/blacklist-nouveau.conf with the following contents.


    ```bash
    touch /etc/modprobe.d/blacklist-nouveau.conf
    echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nouveau.conf
    echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nouveau.conf
    ```

---
## Step 2. Edit the APT sources file and update the packages information
---

Open the file /etc/apt/sources.list and add `non-free` and `contrib` after `main` entry for the binary and source packages. Update apt repositories.


    ```bash
    nano /etc/apt/sources.list
    # For example, the modifications for bookworm and deb.debian.org mirror
    # deb http://deb.debian.org/debian/ bookworm main non-free contrib non-free-firmware
    # deb-src http://deb.debian.org/debian/ bookworm main non-free contrib non-free-firmware
    apt update
    ```

---
## Step 3. Add the NVIDIA's repository for the CUDA version you target
---

For CUDA 12.1, the version is available in the Bullseye repository.
Add the Bullseye and the Bookworm repositories.


    ```bash
    curl -fSsL https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/3bf863cc.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/nvidia-drivers-bookworm.gpg > /dev/null 2>&1

    echo 'deb [signed-by=/usr/share/keyrings/nvidia-drivers-bookworm.gpg] https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/ /' | sudo tee /etc/apt/sources.list.d/nvidia-drivers-bookworm.list

    curl -fSsL https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/3bf863cc.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/nvidia-drivers-bullseye.gpg > /dev/null 2>&1

    echo 'deb [signed-by=/usr/share/keyrings/nvidia-drivers-bullseye.gpg] https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/ /' | sudo tee /etc/apt/sources.list.d/nvidia-drivers-bullseye.list
    nano /etc/apt/sources.list

    apt update
    ```

---
## Step 4. Create an APT preferences file to stay with NVIDIA drivers compatible with CUDA 12.1
---

You could install other version that is compatible with CUDA 12.1 based on the following information:
https://docs.nvidia.com/deploy/cuda-compatibility/minor-version-compatibility.html

Drivers version have to be at least in version 525 and lower than version 580.
    
    ```bash
    echo 'Package: *nvidia*
    Pin: version 575.57.08-1
    Pin-Priority: 1001

    Package: cuda-drivers*
    Pin: version 575.57.08-1
    Pin-Priority: 1001

    Package: libcuda*
    Pin: version 575.57.08-1
    Pin-Priority: 1001

    Package: libxnvctrl* 
    Pin: version 575.57.08-1
    Pin-Priority: 1001

    Package: libnv*
    Pin: version 575.57.08-1
    Pin-Priority: 1001' > /etc/apt/preferences.d/nvidia-drivers

    apt-get update
    ```


---
## Step 5. Regenerate the kernel initramfs, download nvidia-driver, cuda and optix
---

    ```bash
    export PATH=$PATH:/sbin
    update-initramfs -u
    apt-get install -d nvidia-driver cuda-toolkit-12-1 libnvoptix1 nvidia-settings cuda-drivers
    ```

---
## Step 6. Go to runlevel 3, install all downloaded packages and reboot
---

    ```bash
    init 3
    apt-get -y install nvidia-driver cuda-toolkit-12-1 libnvoptix1 nvidia-settings cuda-drivers
    reboot
    ```

--
## References
--

    * Linux Capable
    - [How to Install CUDA Toolkit on Debian 12, 11, or 10](ttps://linuxcapable.com/how-to-install-cuda-on-debian-linux/)
    - [How to Install Nvidia Drivers on Debian 12 or 11](https://linuxcapable.com/install-nvidia-drivers-on-debian/)
    * Article from Levente Csikor on medium.com
    https://medium.com/codex/install-nvidia-drivers-cuda-on-debian-12-bookworm-nvidia-smi-69d2980247c6