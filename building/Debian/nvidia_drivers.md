Note 1: Root privileges are required to install the NVIDIA drivers.
Note 2: On recent Debian's distributions, the `sbin` directory is not present in the PATH environment variable.
You may have to update your `.bashrc` file or update the environment variable before launching the commands. 

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
## Step 3. Create an APT preferences file to stay with the 545 version 545 of the nvidia drivers
---
    The version 545 of the drivers is compatible with CUDA 12.1. And MoonRay required at most this version.

    ```bash
    echo 'Package: *nvidia*
Pin: version 545.23.08-1
Pin-Priority: 1001

Package: cuda-drivers*
Pin: version 545.23.08-1
Pin-Priority: 1001

Package: libcuda*
Pin: version 545.23.08-1
Pin-Priority: 1001


Package: libxnvctrl* 
Pin: version 545.23.08-1
Pin-Priority: 1001

Package: libnv*
Pin: version 545.23.08-1
Pin-Priority: 1001' > /etc/apt/preferences.d/nvidia-drivers
    apt-get update
    ```

---
## Step 3. Regenerate the kernel initramfs, download nvidia-driver, cuda and optix
---

    ```bash
    export PATH=$PATH:/sbin
    update-initramfs -u
    apt-get install -d nvidia-driver cuda-toolkit-12-1 libnvoptix1
    ```


---
## Step 4. Boot to runlevel 3, install the NVIDIA drivers and reboot
---

    ```bash
    init 3
    apt-get -y install nvidia-driver cuda-toolkit-12-1 libnvoptix1
    reboot
    ```
