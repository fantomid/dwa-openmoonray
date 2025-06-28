Building MoonRay on Debian Linux

Requires CMake 3.23.1 (or greater)

If you want to include MoonRay GPU support, you will also need to download the NVIDIA Optix headers
(from [here](https://developer.nvidia.com/designworks/optix/downloads/legacy)), which require an EULA.
Be sure to download version 7.3, as MoonRay is not yet compatible with their more recent releases.
Once you have extracted the download contents, note the location of the header files (under *include*): these will be copied to */opt/Moonray/installs/optix* in step 3 below.

To install NVIDIA drivers on Debian, some instructions are available [here](nvidia_drivers.md)

---
## Step 1. Create the folders
---
    Create a clean root folder for moonray.  Attempting to build atop a previous installation may cause issues.
    These can be created in the location of your choosing, but these instruction, the provided CMake presets,
    and several of the scripts mentioned in these instructions assume this location/structure.
    
    ```bash
    mkdir -p /opt/MoonRay/{installs,build,build-deps,source,tmp}
    mkdir -p /opt/MoonRay/installs/{bin,lib,include,optix}
    ```

---
## Step 2. Clone the OpenMoonRay source
---
    ```bash
    cd /opt/MoonRay/source
    git clone --recurse-submodules https://github.com/dreamworksanimation/openmoonray.git
    cd ..
    ```

---
## Step 3. Install some of the dependencies via script/package manager
---
    ```bash
    su
    ./source/openmoonray/building/Debian/install_packages.sh
    ```
    During cuda toolkit installation, uncheck *Driver installation*
    You can add arguments `--nocuda` and `--noqt` to skip GPU and GUI support respectively.
    If you are building with GPU support, copy the Optix headers that you downloaded and extracted into */opt/Moonray/installs/optix*

    ```bash
    cp -r /tmp/optix/include/ /opt/Moonray/installs/optix
    apt-get -y install libnvoptix1
    ```

---
## Step 4. Build the remaining dependencies from source
---
    Note: You may have to adapt the path to build for other Debian's version
    
    ```bash
    cd build-deps
    cmake ../source/openmoonray/building/Debian/bookworm
    cmake --build . -- -j $(nproc)
    ```

---
## Step 5. Patch the source code
---
    Note: Before building MoonRay, the source code has to be patched
    
    ```bash
    cd /opt/MoonRay/source/openmoonray
    ./building/Debian/apply_patch.sh /opt/MoonRay/source/openmoonray
    ```

---
## Step 6. Build MoonRay
---
    Note 1: To build for cpu only, replace debian-bookworm-release-gpu presets below with debian-bookworm-release. 
    Note 2: Before building for cpu and gpu, check that the CUDA compiler is in ypur PATH by launching the nvcc command.
    
    ```bash
    cd /opt/MoonRay/source/openmoonray
    cmake --preset debian-bookworm-release-gpu
    cmake --build --preset debian-bookworm-release-gpu -- -j $(nproc)
    ```

---
## Step 7. Run/Test
---
    ```bash
    source /opt/MoonRay/installs/openmoonray/scripts/setup.sh
    cd /opt/MoonRay/source/openmoonray/testdata
    moonray_gui -exec_mode xpu -info -in curves.rdla
    ```

---
## Step 8. Post-build/install Cleanup
---
    ```bash
    rm -rf /opt/MoonRay/{build,build-deps}
    ```

---
## Step 9. Create the Debian package
---
    ```bash
    cd /opt/MoonRay/source/openmoonray
    ./building/Debian/make_deb.sh /opt/MoonRay/source/openmoonray /opt/MoonRay/installs
    ```
