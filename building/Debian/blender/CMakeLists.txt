# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# These ExternalProject targets can be used to download, build and
# install many of the Moonray dependencies.
# The targets are chained using dependencies so that they run
# serially.

cmake_minimum_required (VERSION 3.23.1)
project(openmoonray_third_party)

include(ExternalProject)

if(NOT DEFINED MOONRAY_INSTALL_ROOT)
    message(FATAL_ERROR "The MoonRay install root directory for dependencies is mandatory, use -DMOONRAY_INSTALL_ROOT=<Directory> on the cmake command line\n")
endif()

if(NOT DEFINED BLENDER_VERSION)
    message(FATAL_ERROR "The targeted Blender version is mandatory for dependencies, use -DBLENDER_VERSION=<2 digits version with comma> on the cmake command line\n")
endif()

set(SUPPORTED_BLENDER_VERSION "4.2" "4.5")
if(${BLENDER_VERSION} NOT IN_LIST SUPPORTED_BLENDER_VERSION)
    message(FATAL_ERROR "The given Blender version ${BLENDER_VERSION} is not supported, only LTS version are !\n")
endif()

message("The MoonRay install root directory is ${MOONRAY_INSTALL_ROOT}")
message("The Blender version used is ${BLENDER_VERSION}")
set(InstallRoot ${MOONRAY_INSTALL_ROOT} CACHE FILEPATH "Install root for dependencies")
set(BlenderVersionLibraries ${BLENDER_VERSION} CACHE FILEPATH "Blender version for libraries")

ExternalProject_Add(JsonCpp
   GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp.git
   # GIT_TAG 5defb4ed1a4293b8e2bf641e16b156fb9de498cc # 1.9.5
   GIT_TAG 89e2973c754a9c02a49974d839779b151e95afd6 # 1.9.6
   DOWNLOAD_EXTRACT_TIMESTAMP True
   CMAKE_ARGS
       -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
       -DBUILD_SHARED_LIBS=1
       -DPYTHON_EXECUTABLE=/usr/bin/python3
       -DJSONCPP_LIB_BUILD_SHARED:BOOL=ON
       -DJSONCPP_WITH_PKGCONFIG_SUPPORT=OFF
)
set(CHAIN JsonCpp)

# Boost is not included for the Blender 4.5 libraries
if (BlenderVersionLibraries STREQUAL "4.5")
    ExternalProject_Add(Boost
        URL https://sourceforge.net/projects/boost/files/boost/1.82.0/boost_1_82_0.tar.gz
        UPDATE_COMMAND ./bootstrap.sh --prefix=${InstallRoot} --with-python=${InstallRoot}/bin/python3.11 --with-python-version=3.11 --with-python-root=${InstallRoot}/lib/python3.11
        CONFIGURE_COMMAND ""
        PATCH_COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/boost_1_82_0_project-config.jam ./project-config.jam
        BUILD_COMMAND ./b2 install ${JOBS_ARG} --with_python variant=release link=shared threading=multi define=BOOST_UNORDERED_HAVE_PIECEWISE_CONSTRUCT=0
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ""
        DOWNLOAD_EXTRACT_TIMESTAMP True
        DEPENDS ${CHAIN}
    )
    set(CHAIN Boost)
endif()

ExternalProject_Add(Random123
   GIT_REPOSITORY https://github.com/DEShawResearch/random123
   GIT_TAG 726a093cd9a73f3ec3c8d7a70ff10ed8efec8d13 # v1.14.0
   BUILD_IN_SOURCE 1
   CONFIGURE_COMMAND ""
   BUILD_COMMAND ""
   DOWNLOAD_EXTRACT_TIMESTAMP True
   INSTALL_COMMAND make install-include prefix=${InstallRoot}
   DEPENDS ${CHAIN}
)
set(CHAIN Random123)

ExternalProject_Add(ISPC
    URL https://github.com/ispc/ispc/releases/download/v1.20.0/ispc-v1.20.0-linux.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    DOWNLOAD_EXTRACT_TIMESTAMP True
    INSTALL_COMMAND cp bin/ispc ${InstallRoot}/bin
    DEPENDS ${CHAIN}
)
set(CHAIN ISPC)

ExternalProject_Add(embree
    URL https://github.com/RenderKit/embree/releases/download/v4.4.0/embree-4.4.0.x86_64.linux.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    DOWNLOAD_EXTRACT_TIMESTAMP True
    INSTALL_COMMAND cp include/embree4/*.isph ${InstallRoot}/include/embree4
    DEPENDS ${CHAIN}
)
set(CHAIN embree)
