vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcat/openal-soft
    REF c1c63a27de66cd44ef756b190a73bfa8bc6dbbab # openal-soft-1.22.0
    SHA512 3d403a2c292991976880254dd6374e7f501e6b56183bfd935f5f640f250fb935f95537faf49a3ef42d75c993475971f56da8118c54c8c6668e951d1a5e576139
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENAL_LIBTYPE "SHARED")
else()
    set(OPENAL_LIBTYPE "STATIC")
endif()

set(ALSOFT_REQUIRE_LINUX OFF)
set(ALSOFT_REQUIRE_WINDOWS OFF)
set(ALSOFT_REQUIRE_APPLE OFF)

if(VCPKG_TARGET_IS_LINUX)
    set(ALSOFT_REQUIRE_LINUX ON)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    set(ALSOFT_REQUIRE_WINDOWS ON)
endif()
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(ALSOFT_REQUIRE_APPLE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBTYPE=${OPENAL_LIBTYPE}
        -DALSOFT_UTILS=OFF
        -DALSOFT_NO_CONFIG_UTIL=ON
        -DALSOFT_EXAMPLES=OFF
        -DALSOFT_CONFIG=OFF
        -DALSOFT_HRTF_DEFS=OFF
        -DALSOFT_AMBDEC_PRESETS=OFF
        -DALSOFT_BACKEND_ALSA=${ALSOFT_REQUIRE_LINUX}
        -DALSOFT_BACKEND_OSS=OFF
        -DALSOFT_BACKEND_SOLARIS=OFF
        -DALSOFT_BACKEND_SNDIO=OFF
        -DALSOFT_BACKEND_PORTAUDIO=OFF
        -DALSOFT_BACKEND_PULSEAUDIO=OFF
        -DALSOFT_BACKEND_COREAUDIO=${ALSOFT_REQUIRE_APPLE}
        -DALSOFT_BACKEND_JACK=OFF
        -DALSOFT_BACKEND_OPENSL=${VCPKG_TARGET_IS_ANDROID}
        -DALSOFT_BACKEND_WAVE=ON
        -DALSOFT_BACKEND_WINMM=OFF
        -DALSOFT_BACKEND_DSOUND=OFF
        -DALSOFT_REQUIRE_WASAPI=${ALSOFT_REQUIRE_WINDOWS}
        -DALSOFT_CPUEXT_NEON=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_WindowsSDK=ON
    MAYBE_UNUSED_VARIABLES
        ALSOFT_AMBDEC_PRESETS
        ALSOFT_BACKEND_ALSA
        ALSOFT_BACKEND_COREAUDIO
        ALSOFT_BACKEND_JACK
        ALSOFT_BACKEND_OPENSL
        ALSOFT_BACKEND_OSS
        ALSOFT_BACKEND_PORTAUDIO
        ALSOFT_BACKEND_PULSEAUDIO
        ALSOFT_BACKEND_SNDIO
        ALSOFT_BACKEND_SOLARIS
        ALSOFT_CONFIG
        ALSOFT_CPUEXT_NEON
        ALSOFT_HRTF_DEFS
        CMAKE_DISABLE_FIND_PACKAGE_WindowsSDK
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/OpenAL")

foreach(HEADER al.h alc.h)
    file(READ "${CURRENT_PACKAGES_DIR}/include/AL/${HEADER}" AL_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(AL_LIBTYPE_STATIC)" "1" AL_H "${AL_H}")
    else()
        # Normally we would say:
        # string(REPLACE "defined(AL_LIBTYPE_STATIC)" "0" AL_H "${AL_H}")
        # but we are leaving these undefined macros alone in support of
        # https://github.com/microsoft/vcpkg/issues/18098
    endif()
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/AL/${HEADER}" "${AL_H}")
endforeach()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()
