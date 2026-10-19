#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/amazon/giza

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := giza

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest_giza.xml

# Kernel
TARGET_KERNEL_CONFIG := giza_defconfig

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
BOARD_CACHEIMAGE_PARTITION_SIZE := 444596224
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1692696576

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Inherit from mt8163-common
include device/amazon/mt8163-common/BoardConfigCommon.mk

# Inherit the proprietary files
include vendor/amazon/giza/BoardConfigVendor.mk
