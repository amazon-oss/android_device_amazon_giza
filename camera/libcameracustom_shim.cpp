/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "libcameracustom_shim"

#include <dlfcn.h>
#include <stdint.h>
#include <string.h>

#include <memory>
#include <mutex>

#include <log/log.h>

struct MSDK_SENSOR_INIT_FUNCTION_STRUCT {
    uint32_t sensorId;
    char drvName[32];
    void* info;
    void* getInstance;
    int (*getCameraDefault)(int type, void* data, uint32_t size);
    void* reserved;
    void* getCameraCalData;
};
static_assert(sizeof(MSDK_SENSOR_INIT_FUNCTION_STRUCT) == 56);

namespace NSCamCustomSensor {
enum EDevId {};
}  // namespace NSCamCustomSensor

namespace {

using GetCameraDefault = int (*)(int, void*, uint32_t);

constexpr int kAePlineTable = 4;

constexpr size_t kPlineMappingSize = 0x5a0;
constexpr size_t kPlineTableCount = 50;
constexpr size_t kPlineTableSize = 6436;
constexpr size_t kPlineTableStride = 6440;
constexpr size_t kPlineTrailerSize = 9226;
constexpr size_t kOldPlineSize = 0x512b4;
constexpr size_t kNewPlineSize = 0x51380;

constexpr size_t kMaxSensors = 4;

void* handle;
MSDK_SENSOR_INIT_FUNCTION_STRUCT sensorList[kMaxSensors + 1];
GetCameraDefault gizaGetCameraDefault[kMaxSensors];

void convertPline(uint8_t* dst, const uint8_t* src) {
    memset(dst, 0, kNewPlineSize);
    memcpy(dst, src, kPlineMappingSize);

    dst += kPlineMappingSize;
    src += kPlineMappingSize;
    for (size_t i = 0; i < kPlineTableCount; i++) {
        memcpy(dst, src, kPlineTableSize);
        dst += kPlineTableStride;
        src += kPlineTableSize;
    }

    memcpy(dst, src, kPlineTrailerSize);
}

template <size_t N>
int getCameraDefault(int type, void* data, uint32_t size) {
    if (type != kAePlineTable)
        return gizaGetCameraDefault[N](type, data, size);

    if (data == nullptr || size < kNewPlineSize)
        return 1;

    std::unique_ptr<uint8_t[]> pline(new uint8_t[kOldPlineSize]);
    int ret = gizaGetCameraDefault[N](type, pline.get(), kOldPlineSize);
    if (ret == 0)
        convertPline(static_cast<uint8_t*>(data), pline.get());

    return ret;
}

constexpr GetCameraDefault kGetCameraDefault[kMaxSensors] = {
        getCameraDefault<0>,
        getCameraDefault<1>,
        getCameraDefault<2>,
        getCameraDefault<3>,
};

void init() {
    handle = dlopen("libcameracustom_giza.so", RTLD_NOW | RTLD_LOCAL);
    LOG_ALWAYS_FATAL_IF(handle == nullptr, "Failed to load libcameracustom_giza: %s",
                        dlerror());

    auto getList = reinterpret_cast<uint32_t (*)(MSDK_SENSOR_INIT_FUNCTION_STRUCT**)>(
            dlsym(handle, "_Z21GetSensorInitFuncListPP32MSDK_SENSOR_INIT_FUNCTION_STRUCT"));
    MSDK_SENSOR_INIT_FUNCTION_STRUCT* list = nullptr;
    LOG_ALWAYS_FATAL_IF(getList == nullptr || getList(&list) != 0 || list == nullptr,
                        "Failed to get the giza sensor list");

    for (size_t i = 0; i < kMaxSensors && list[i].sensorId != 0; i++) {
        sensorList[i] = list[i];
        if (list[i].getCameraDefault == nullptr) continue;

        gizaGetCameraDefault[i] = list[i].getCameraDefault;
        sensorList[i].getCameraDefault = kGetCameraDefault[i];
    }
}

template <typename T>
T resolve(const char* name) {
    static std::once_flag once;
    std::call_once(once, init);

    void* sym = dlsym(handle, name);
    LOG_ALWAYS_FATAL_IF(sym == nullptr, "Failed to resolve %s: %s", name, dlerror());
    return reinterpret_cast<T>(sym);
}

}  // namespace

uint32_t GetSensorInitFuncList(MSDK_SENSOR_INIT_FUNCTION_STRUCT** list) {
    static std::once_flag once;
    std::call_once(once, init);

    if (list == nullptr)
        return 0x80000000;

    *list = sensorList;
    return 0;
}

#define FORWARD(ret, name, mangled)                                \
    ret name() {                                                   \
        static const auto fn = resolve<ret (*)()>(mangled);        \
        return fn();                                               \
    }

#define FORWARD_DEV(ret, name, mangled)                            \
    ret name(EDevId id) {                                          \
        static const auto fn = resolve<ret (*)(EDevId)>(mangled);  \
        return fn(id);                                             \
    }

namespace NSCamCustomSensor {

FORWARD(const void*, getSensorOrientation, "_ZN17NSCamCustomSensor20getSensorOrientationEv")
FORWARD(const void*, getSensorViewAngle, "_ZN17NSCamCustomSensor18getSensorViewAngleEv")
FORWARD(bool, isRetFakeMainOrientation, "_ZN17NSCamCustomSensor24isRetFakeMainOrientationEv")
FORWARD(bool, isRetFakeSubOrientation, "_ZN17NSCamCustomSensor23isRetFakeSubOrientationEv")
FORWARD(bool, isRetFakeMain2Orientation, "_ZN17NSCamCustomSensor25isRetFakeMain2OrientationEv")

FORWARD_DEV(int, getSensorFacingDirection,
            "_ZN17NSCamCustomSensor24getSensorFacingDirectionENS_6EDevIdE")
FORWARD_DEV(int, getMipiSensorPort, "_ZN17NSCamCustomSensor17getMipiSensorPortENS_6EDevIdE")
FORWARD_DEV(int, getSensorMclkConnection,
            "_ZN17NSCamCustomSensor23getSensorMclkConnectionENS_6EDevIdE")
FORWARD_DEV(int, getSensorPadPclkInv, "_ZN17NSCamCustomSensor19getSensorPadPclkInvENS_6EDevIdE")
FORWARD_DEV(int, getSensorInputDataBitOrder,
            "_ZN17NSCamCustomSensor26getSensorInputDataBitOrderENS_6EDevIdE")

}  // namespace NSCamCustomSensor
