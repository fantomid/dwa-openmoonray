Building MoonRay on Debian Linux

Requires CMake 3.23.1 (or greater)

If you want to include MoonRay GPU support, you will also need to download the NVIDIA Optix headers
(from [here](https://developer.nvidia.com/designworks/optix/downloads/legacy)), which require an EULA.
Be sure to download version 7.3, as MoonRay is not yet compatible with their more recent releases.
Once you have extracted the download contents, note the location of the header files (under *include*): these will be copied to */opt/Moonray/installs/optix* in step 3 below.

---
## Step 1. Create the folders
---
    Create a clean root folder for moonray.  Attempting to build atop a previous installation may cause issues.
    These can be created in the location of your choosing, but these instruction, the provided CMake presets,
    and several of the scripts mentioned in these instructions assume this location/structure.
    ```
    mkdir -p /opt/MoonRay/{installs,build,build-deps,source,tmp}
    mkdir -p /opt/MoonRay/installs/{bin,lib,include,optix}
    ```

---
## Step 2. Clone the OpenMoonRay source
---
    ```
    cd /opt/MoonRay/source
    git clone --recurse-submodules https://github.com/dreamworksanimation/openmoonray.git
    cd ..
    ```

---
## Step 3. Install some of the dependencies via script/package manager
---
    ```bash
    sudo source source/openmoonray/building/Debian/install_packages.sh
    ```
    During cuda toolkit installation, uncheck *Driver installation*
    You can add arguments `--nocuda` and `--noqt` to skip GPU and GUI support respectively.
    If you are building with GPU support, copy the Optix headers that you downloaded and extracted into */opt/Moonray/installs/optix*

    ```bash
    cp -r /tmp/optix/include/* /opt/Moonray/installs/optix
    ```

---
## Step 4. Build the remaining dependencies from source
---
    ```
    cd build-deps
    cmake ../source/openmoonray/building/Debian/bookworm
    cmake --build . -- -j $(nproc)
    ```

---
## Step 5. Patch the source code
---
    Note: Before building MoonRay, the source code has to be patched
    ```
    cd /opt/MoonRay/source/openmoonray
    ./building/Debian/bookworm/apply_patch.sh /opt/MoonRay/source/openmoonray
    ```

---
## Step 6. Build MoonRay
---
    Note: If building for cpu only, replace debian-bookworm-release-gpu presets below with debian-bookworm-release
    ```
    cd /opt/MoonRay/source/openmoonray
    cmake --preset debian-bookworm-release-gpu
    cmake --build --preset debian-bookworm-release-gpu -- -j $(nproc)
    ```

---
## Step 6. Run/Test
---
    ```
    source /opt/MoonRay/installs/openmoonray/scripts/setup.sh
    cd /opt/MoonRay/source/openmoonray/testdata
    moonray_gui -exec_mode xpu -info -in curves.rdla
    ```

---
## Step 8. Post-build/install Cleanup/create 
---
    ```
    rm -rf /opt/MoonRay/{build,build-deps}
    ```

---
## Step 9. Create the Debian package
---
    Note: If MoonRay was built only for cpu, add the argumment `--cpu` at the end of the command line
    ```
    cd /opt/MoonRay/source/openmoonray
    ./building/Debian/bookworm/make_deb.sh /opt/MoonRay/source/openmoonray /opt/MoonRay/install
    ```
