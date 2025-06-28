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
## Step 2. Regenerate the kernel initramfs and reboot
---
    ```bash
    export PATH=$PATH:/sbin
    update-initramfs -u
    reboot
    ```

---
## Step 3. Edit the APT sources file and update the packages information
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
## Step 4. Install the NVIDIA drivers
---
    The login screen could be not available after you disable the nouveau's driver (no window environment).
    In that case, you have to login to the system with root privileges in a terminal screen and then install the nvidia driver with the command:
    
    ```bash
    apt-get -y install nvidia-driver
    reboot
    ```
