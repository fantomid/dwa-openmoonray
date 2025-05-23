# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# These ExternalProject targets can be used to download, build and
# install many of the Moonray dependencies.
# The targets are chained using dependencies so that they run
# serially.

cmake_minimum_required (VERSION 3.23.1)
project(openmoonray_third_party)

include(ExternalProject)

set(InstallRoot /opt/MoonRay/installs CACHE FILEPATH "Install root for dependencies")

ExternalProject_Add(JsonCpp
    GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp.git
#     GIT_TAG 5defb4ed1a4293b8e2bf641e16b156fb9de498cc # 1.9.5
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

ExternalProject_Add(TBB
    GIT_REPOSITORY https://github.com/uxlfoundation/oneTBB
    GIT_TAG 81e4471d1191c75e0a78311c584b64b6591da842 # v2020.3.3
    DOWNLOAD_EXTRACT_TIMESTAMP True
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make tbb tbbmalloc tbbproxy tbbbind ${JOBS_ARG}
    INSTALL_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/install_tbb_2020.3.sh ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${InstallRoot}
    DEPENDS ${CHAIN}
)
set(CHAIN TBB)

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

If(NOT BUILD_WITH_BLENDER_LIBS)
    ExternalProject_Add(Boost
       URL https://sourceforge.net/projects/boost/files/boost/1.78.0/boost_1_78_0.tar.gz
       UPDATE_COMMAND ./bootstrap.sh --prefix=${InstallRoot}
       CONFIGURE_COMMAND ""
       BUILD_COMMAND ./b2 install ${JOBS_ARG} --with_python variant=release link=shared threading=multi define=BOOST_UNORDERED_HAVE_PIECEWISE_CONSTRUCT=0
       BUILD_IN_SOURCE 1
       INSTALL_COMMAND ""
       DOWNLOAD_EXTRACT_TIMESTAMP True
       DEPENDS ${CHAIN}
   )
   set(CHAIN Boost)

   ExternalProject_Add(OpenVDB
       GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/openvdb
       GIT_TAG ab935574cdb25c3df66b068fce2a3b0a74281c54 # v9.1.0
       PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/../openvdb-9.1.0.patch
       DOWNLOAD_EXTRACT_TIMESTAMP True
       CMAKE_ARGS
           -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
           -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake
           -DTBB_USE_STATIC_LIBS=NO
       DEPENDS ${CHAIN}
   )
   set(CHAIN OpenVDB)
)

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
    GIT_REPOSITORY https://github.com/embree/embree
    GIT_TAG 341ef8c45d1ae072ead1ab65cd76e88b03d9302c # v4.2.0
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake
        -DEMBREE_ISPC_EXECUTABLE=${InstallRoot}/bin/ispc
        -DEMBREE_ISPC_SUPPORT=ON
        -DEMBREE_IGNORE_INVALID_RAYS=ON
        -DEMBREE_RAY_MASK=ON
        -DEMBREE_MAX_ISA=AVX512
        -DEMBREE_TUTORIALS=OFF
        -DBUILD_SHARED_LIBS=ON
    DEPENDS ${CHAIN}
)
set(CHAIN embree)

ExternalProject_Add(OpenSubdiv
    GIT_REPOSITORY https://github.com/PixarAnimationStudios/OpenSubdiv
    GIT_TAG 8ffa2b6566be10209529d7a0d1db02a0796b160c # v3_5_0
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
      -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake
      -DCMAKE_BUILD_TYPE=Release
      -DNO_PTEX=1 -DNO_OMP=1 -DNO_TBB=1 -DNO_CUDA=1 -DNO_GLFW_X11=1 -DNO_DOC=1
      -DNO_OPENCL=1 -DNO_CLEW=1 -DNO_REGRESSION=1 -DNO_EXAMPLES=1 -DNO_TUTORIALS=1 -DNO_GLTESTS=1
      -DNO_MACOS_FRAMEWORK=1 -DNO_METAL=1 -DNO_TESTS=1
    DEPENDS ${CHAIN}
)
set(CHAIN OpenSubdiv)

ExternalProject_Add(OpenEXR
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/openexr
    GIT_TAG 8bc3741131db146ad08a5b83af9e6e48f0e94a03 # v2.5.7
    PATCH_COMMAND patch IlmBase/Half/CMakeLists.txt ${CMAKE_CURRENT_SOURCE_DIR}/../../Imath_include_paths.patch
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake
        -DBUILD_SHARED_LIBS=OFF
DEPENDS ${CHAIN}
)
set(CHAIN OpenEXR)

ExternalProject_Add(OpenColorIO
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/OpenColorIO
    GIT_TAG 056b7b0cb0d087961e9dba75104820e44faf52a1 # v2.0.2
    PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/../opencolorio-2.0.2-gcc12.patch
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
        -DOCIO_BUILD_APPS=OFF
        -DOCIO_BUILD_TESTS=OFF
        -DOCIO_BUILD_GPU_TESTS=OFF
        -DOCIO_USE_SSE=OFF
        -DOCIO_BUILD_PYTHON=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake        
        -DBUILD_SHARED_LIBS=ON
        -DOCIO_BUILD_STATIC=OFF
        -DCMAKE_CXX_STANDARD=17
    DEPENDS ${CHAIN}
)
set(CHAIN OpenColorIO)

ExternalProject_Add(OpenImageIO
    GIT_REPOSITORY https://github.com/OpenImageIO/oiio
    GIT_TAG 331a323468928c8017ad048b26d47c4e57a724a7 # 2.3.20.0
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
        -DOpenEXR_ROOT=${InstallRoot}
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake        
        -DUSE_QT=0
        -DUSE_PYTHON=0
        -DOIIO_BUILD_TOOLS=0
        -DOIIO_BUILD_TESTS=0
    DEPENDS ${CHAIN}
)
set(CHAIN OpenImageIO)

ExternalProject_Add(OpenImageDenoise
    URL https://github.com/OpenImageDenoise/oidn/releases/download/v2.0.1/oidn-2.0.1.src.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP True
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_MODULE_PATH:PATH=${InstallRoot}/lib/cmake
        -DISPC_EXECUTABLE=${InstallRoot}/bin/ispc
        -DOIDN_APPS=OFF
    DEPENDS ${CHAIN}
)
set(CHAIN OpenImageDenoise)

if(NOT NO_USD)
    if (USD_23_11_BLENDER_4_1)
        ExternalProject_Add(USD
            GIT_REPOSITORY https://github.com/PixarAnimationStudios/USD
            GIT_TAG 0b18ad3f840c24eb25e16b795a5b0821cf05126e # v23.11 Blender 4.1
            DOWNLOAD_EXTRACT_TIMESTAMP True
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
                -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
                -DCMAKE_MODULE_PATH=${InstallRoot}/lib/cmake
                -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
                -DPXR_ENABLE_PYTHON_SUPPORT=ON
                -DPXR_USE_PYTHON_3=ON
                -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
                -DPXR_BUILD_TESTS=OFF
                -DPXR_BUILD_EXAMPLES=OFF
                -DPXR_BUILD_TUTORIALS=OFF
                -DPXR_BUILD_USD_TOOLS=OFF
                -DPXR_ENABLE_PTEX_SUPPORT=OFF
                -DPXR_ENABLE_OPENVDB_SUPPORT=ON
                -DPXR_BUILD_USDVIEW=OFF
                -DTBB_USE_DEBUG_BUILD=OFF
            DEPENDS ${CHAIN}
        )
    # elseif(USD_24_05_BLENDER_4_2)
    #     ExternalProject_Add(USD
    #         GIT_REPOSITORY https://github.com/PixarAnimationStudios/USD
    #         GIT_TAG 2864f3d04f396432f22ec5d6928fc37d34bb4c90 # v24.05 Blender 4.2
    #         DOWNLOAD_EXTRACT_TIMESTAMP True
    #         CMAKE_ARGS
    #             -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
    #             -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
    #             -DCMAKE_MODULE_PATH=${InstallRoot}/lib/cmake
    #             -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
    #             -DPXR_ENABLE_PYTHON_SUPPORT=ON
    #             -DPXR_USE_PYTHON_3=ON
    #             -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
    #             -DPXR_BUILD_TESTS=OFF
    #             -DPXR_BUILD_EXAMPLES=OFF
    #             -DPXR_BUILD_TUTORIALS=OFF
    #             -DPXR_BUILD_USD_TOOLS=OFF
    #             -DPXR_ENABLE_PTEX_SUPPORT=OFF
    #             -DPXR_ENABLE_OPENVDB_SUPPORT=ON
    #             -DPXR_BUILD_USDVIEW=OFF
    #             -DTBB_USE_DEBUG_BUILD=OFF
    #         DEPENDS ${CHAIN}
    #     )
    # elseif(USD_25_02_BLENDER_4_4)
    #     ExternalProject_Add(USD
    #         GIT_REPOSITORY https://github.com/PixarAnimationStudios/USD
    #         GIT_TAG ba8aaf1f9e3d72822ce9c9041a6dd75e4eb53906 # v25.02 Blender 4.4
    #         DOWNLOAD_EXTRACT_TIMESTAMP True
    #         CMAKE_ARGS
    #             -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
    #             -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
    #             -DCMAKE_MODULE_PATH=${InstallRoot}/lib/cmake
    #             -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
    #             -DPXR_ENABLE_PYTHON_SUPPORT=ON
    #             -DPXR_USE_PYTHON_3=ON
    #             -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
    #             -DPXR_BUILD_TESTS=OFF
    #             -DPXR_BUILD_EXAMPLES=OFF
    #             -DPXR_BUILD_TUTORIALS=OFF
    #             -DPXR_BUILD_USD_TOOLS=OFF
    #             -DPXR_ENABLE_PTEX_SUPPORT=OFF
    #             -DPXR_ENABLE_OPENVDB_SUPPORT=ON
    #             -DPXR_BUILD_USDVIEW=OFF
    #             -DPXR_BUILD_MONOLITHIC=ON
    #             -DPXR_MONOLITHIC_IMPORT:PATH=${InstallRoot}
    #             -DTBB_USE_DEBUG_BUILD=OFF
    #         DEPENDS ${CHAIN}
    #     )
    else()
        ExternalProject_Add(USD
            GIT_REPOSITORY https://github.com/PixarAnimationStudios/USD
            GIT_TAG 0c7b9a95f155c221ff7df9270a39a52e3b23af8b # v22.11
            PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/../usd-22.11.patch
            DOWNLOAD_EXTRACT_TIMESTAMP True
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
                -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
                -DCMAKE_MODULE_PATH=${InstallRoot}/lib/cmake
                -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
                -DPXR_ENABLE_PYTHON_SUPPORT=ON
                -DPXR_USE_PYTHON_3=ON
                -DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON
                -DPXR_BUILD_TESTS=OFF
                -DPXR_BUILD_EXAMPLES=OFF
                -DPXR_BUILD_TUTORIALS=OFF
                -DPXR_BUILD_USD_TOOLS=OFF
                -DPXR_ENABLE_PTEX_SUPPORT=OFF
                -DPXR_ENABLE_OPENVDB_SUPPORT=ON
                -DPXR_BUILD_USDVIEW=OFF
                -DTBB_USE_DEBUG_BUILD=OFF
            DEPENDS ${CHAIN}
        )
    endif()
    set(CHAIN USD)
endif()

