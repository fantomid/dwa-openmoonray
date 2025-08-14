Building MoonRay for Blender on Debian Linux

Requires CMake 3.23.1 (or greater)

If you want to include MoonRay GPU support, you will also need to download the NVIDIA Optix headers
(from [here](https://developer.nvidia.com/designworks/optix/downloads/legacy)), which require an EULA.
Be sure to download version 7.3, as MoonRay is not yet compatible with their more recent releases.
Once you have extracted the download contents, note the location of the header files (under *include*): these will be copied to */opt/Moonray/optix* in step 3 below.

To install NVIDIA drivers on Debian, some instructions are available [here](nvidia_drivers.md)

---
## Step 1. Create the folders
---
    Create a clean root folder for moonray.  Attempting to build atop a previous installation may cause issues.
    These can be created in the location of your choosing, but these instruction, the provided CMake presets,
    and several of the scripts mentioned in these instructions assume this location/structure.
    
    ```bash
    mkdir -p /opt/DreamWorksAnimation/tmp_dirs/{build,build-deps,source,tmp}
    mkdir -p /opt/DreamWorksAnimation/{bin,lib,share,optix,include}
    mkdir /opt/DreamWorksAnimation/lib/cmake
    ```

---
## Step 2. Clone the OpenMoonRay source
---
    ```bash
    cd /opt/DreamWorksAnimation/tmp_dirs/source
    git clone --recurse-submodules https://github.com/fantomid/dwa-openmoonray.git openmoonray
    cd ..
    ```

---
## Step 3. Install some of the dependencies via script/package manager
---
    ```bash
    su
    ./source/openmoonray/building/Debian/blender/install_packages.sh
    exit
    ```
    During cuda toolkit installation, uncheck *Driver installation*
    You can add argument `--noqt` to skip GUI support.
    For GPU support, copy the Optix headers that you downloaded and extracted into */opt/Moonray/optix*

    ```bash
    cp -r /tmp/optix/include/ /opt/DreamWorksAnimation/optix
    apt-get -y install libnvoptix1
    ```

---
## Step 4. Install the libraries used by the Blender version
---

    ```bash
    cd /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray
    ./building/Debian/blender/install_blender_libraries.sh 4.2 /opt/DreamWorksAnimation/tmp_dirs/build-deps /opt/DreamWorksAnimation
    ```

---
## Step 5. Build the remaining dependencies from source
---

    ```bash
    cd build-deps
    cmake ../source/openmoonray/building/Debian/blender -DBLENDER_VERSION=4.2 -DMOONRAY_INSTALL_ROOT=/opt/DreamWorksAnimation
    cmake --build . -- -j $(nproc)
    ```

---
## Step 6. Patch the source code
---
    Note: Before building MoonRay, the source code has to be patched

    ```bash
    cd /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray
    ./building/Debian/blender/apply_patch.sh 4.2 /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray
    ```

---
## Step 6. Build MoonRay
---
    Note: Before building, check that the CUDA compiler is in your PATH by launching the `nvcc` command.

    ```bash
    cd /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray
    cmake --preset debian-bookworm-blender-release
    cmake --build --preset debian-bookworm-blender-release -- -j $(nproc)
    ```

---
## Step 7. Run/Test
---

    ```bash
    source /opt/DreamWorksAnimation/openmoonray/scripts/setup.sh
    cd /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray/testdata
    moonray_gui -exec_mode xpu -info -in curves.rdla
    ```

---
## Step 8. Post-build/install Cleanup
---

    ```bash
    rm -rf /opt/DreamWorksAnimation/tmp_dirs
    ```

---
## Step 9. Create the Debian package
---

    ```bash
    cd /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray
    ./building/Debian/blender/make_deb.sh 4.2 /opt/DreamWorksAnimation/tmp_dirs/source/openmoonray /opt/DreamWorksAnimation
    ```
