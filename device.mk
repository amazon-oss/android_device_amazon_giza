#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := hdpi

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio.effect@2.0-impl \
    audio.primary.amazon_wrapper

PRODUCT_PACKAGES += \
    libaudio-resampler \
    libaudioutils \
    libaudioroute \
    libtinyalsa \
    libamazonlog \
    libbinder_shim \
    libcutils_shim

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service \
    android.hardware.bluetooth@1.0-impl \
    libbt-vendor

PRODUCT_PACKAGES += \
    mt66xx_bt

# Connsys
PRODUCT_PACKAGES += \
    mt66xx_common

# Init scripts
PRODUCT_PACKAGES += \
    init.giza.conn.rc \
    init.target.giza.rc

# Screen
TARGET_SCREEN_DENSITY := 213
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 800

# Sensors
PRODUCT_PACKAGES += \
    sensors.amazon_wrapper

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/_hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/_hals.conf

# Shipping API Level
PRODUCT_SHIPPING_API_LEVEL := 22

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service-lazy

PRODUCT_PACKAGES += \
    mt66xx_wlan

PRODUCT_PACKAGES += \
    WifiResOverlayGiza

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/wifi/,$(TARGET_COPY_OUT_VENDOR)/etc/wifi)

# Vendor partition
TARGET_HAS_VENDOR_PARTITION := false

# Inherit from mt8163-common
$(call inherit-product, device/amazon/mt8163-common/mt8163.mk)

# Inherit the proprietary files
$(call inherit-product, vendor/amazon/giza/giza-vendor.mk)
