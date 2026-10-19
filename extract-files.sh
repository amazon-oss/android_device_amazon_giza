#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib*/hw/audio.primary_amazon.mt8163.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            "${PATCHELF}" --add-needed "libcompiler_rt.so" "${2}"
            "${PATCHELF}" --add-needed "libcutils_shim.so" "${2}"
            ;;
        vendor/lib/libblisrc32.so)
            sed -i "s/\x1e\x00\x00\x00\x08\x00\x00\x00/\x1e\x00\x00\x00\x0a\x00\x00\x00/" "${2}"
            ;;
        vendor/lib/libaudiocomponentengine.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            "${PATCHELF}" --add-needed "libutilscallstack.so" "${2}"
            ;;
        vendor/lib/libaudiocustparam.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            ;;
        vendor/lib/libaudiostream.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            "${PATCHELF}" --add-needed "libbinder_shim.so" "${2}"
            "${PATCHELF}" --add-needed "libcutils_shim.so" "${2}"
            ;;
        vendor/lib/libaudiostream_jni.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            ;;
        vendor/lib/libnvram_daemon_callback.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            ;;
        vendor/lib/libnvramagentclient.so)
            "${PATCHELF}" --add-needed "libbinder_shim.so" "${2}"
            ;;
        vendor/lib/libsensors.mt8163.so)
            "${PATCHELF}" --add-needed "libamazonlog.so" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=giza
export DEVICE_COMMON=mt8163-common
export VENDOR=amazon

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
