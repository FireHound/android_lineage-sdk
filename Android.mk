# Copyright (C) 2015 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
LOCAL_PATH := $(call my-dir)

# We have a special case here where we build the library's resources
# independently from its code, so we need to find where the resource
# class source got placed in the course of building the resources.
# Thus, the magic here.
# Also, this module cannot depend directly on the R.java file; if it
# did, the PRIVATE_* vars for R.java wouldn't be guaranteed to be correct.
# Instead, it depends on the R.stamp file, which lists the corresponding
# R.java file as a prerequisite.
lineage_platform_res := APPS/org.lineageos.platform-res_intermediates/src

# List of packages used in lineage-api-stubs
lineage_stub_packages := lineageos.alarmclock:lineageos.app:lineageos.content:lineageos.externalviews:lineageos.hardware:lineageos.media:lineageos.os:lineageos.preference:lineageos.profiles:lineageos.providers:lineageos.platform:lineageos.power:lineageos.util:lineageos.weather:lineageos.weatherservice

# The LineageOS Platform Framework Library
# ============================================================
include $(CLEAR_VARS)

lineage_sdk_src := sdk/src/java/lineageos
lineage_sdk_internal_src := sdk/src/java/org/lineageos/internal
library_src := lineage/lib/main/java

LOCAL_MODULE := org.lineageos.platform
LOCAL_MODULE_TAGS := optional

lineage_sdk_LOCAL_JAVA_LIBRARIES := \
    android-support-v7-preference \
    android-support-v7-recyclerview \
    android-support-v14-preference

LOCAL_JAVA_LIBRARIES := \
    services \
    org.lineageos.hardware \
    $(lineage_sdk_LOCAL_JAVA_LIBRARIES)

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(lineage_sdk_src)) \
    $(call all-java-files-under, $(lineage_sdk_internal_src)) \
    $(call all-java-files-under, $(library_src))

## READ ME: ########################################################
##
## When updating this list of aidl files, consider if that aidl is
## part of the SDK API.  If it is, also add it to the list below that
## is preprocessed and distributed with the SDK.  This list should
## not contain any aidl files for parcelables, but the one below should
## if you intend for 3rd parties to be able to send those objects
## across process boundaries.
##
## READ ME: ########################################################
LOCAL_SRC_FILES += \
    $(call all-Iaidl-files-under, $(lineage_sdk_src)) \
    $(call all-Iaidl-files-under, $(lineage_sdk_internal_src))

lineage_platform_LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_platform_res)/lineageos/platform/R.java \
    $(lineage_platform_res)/lineageos/platform/Manifest.java \
    $(lineage_platform_res)/org/lineageos/platform/internal/R.java

LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_platform_LOCAL_INTERMEDIATE_SOURCES)

# Include aidl files from lineageos.app namespace as well as internal src aidl files
LOCAL_AIDL_INCLUDES := $(LOCAL_PATH)/sdk/src/java
LOCAL_AIDL_FLAGS := -n

include $(BUILD_JAVA_LIBRARY)
lineage_framework_module := $(LOCAL_INSTALLED_MODULE)

# Make sure that R.java and Manifest.java are built before we build
# the source for this library.
lineage_framework_res_R_stamp := \
    $(call intermediates-dir-for,APPS,org.lineageos.platform-res,,COMMON)/src/R.stamp
LOCAL_ADDITIONAL_DEPENDENCIES := $(lineage_framework_res_R_stamp)

$(lineage_framework_module): | $(dir $(lineage_framework_module))org.lineageos.platform-res.apk

lineage_framework_built := $(call java-lib-deps, org.lineageos.platform)

# ====  org.lineageos.platform.xml lib def  ========================
include $(CLEAR_VARS)

LOCAL_MODULE := org.lineageos.platform.xml
LOCAL_MODULE_TAGS := optional

LOCAL_MODULE_CLASS := ETC

# This will install the file in /system/etc/permissions
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions

LOCAL_SRC_FILES := $(LOCAL_MODULE)

include $(BUILD_PREBUILT)

# the sdk
# ============================================================
include $(CLEAR_VARS)

LOCAL_MODULE:= org.lineageos.platform.sdk
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := services

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(lineage_sdk_src)) \
    $(call all-Iaidl-files-under, $(lineage_sdk_src))

# Included aidl files from lineageos.app namespace
LOCAL_AIDL_INCLUDES := $(LOCAL_PATH)/sdk/src/java

lineage_sdk_LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_platform_res)/lineageos/platform/R.java \
    $(lineage_platform_res)/lineageos/platform/Manifest.java

LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_sdk_LOCAL_INTERMEDIATE_SOURCES)

LOCAL_JAVA_LIBRARIES := \
    $(lineage_sdk_LOCAL_JAVA_LIBRARIES)

# Make sure that R.java and Manifest.java are built before we build
# the source for this library.
lineage_framework_res_R_stamp := \
    $(call intermediates-dir-for,APPS,org.lineageos.platform-res,,COMMON)/src/R.stamp
LOCAL_ADDITIONAL_DEPENDENCIES := $(lineage_framework_res_R_stamp)
include $(BUILD_STATIC_JAVA_LIBRARY)

# the sdk as an aar for publish, not built as part of full target
# DO NOT LINK AGAINST THIS IN BUILD
# ============================================================
include $(CLEAR_VARS)

LOCAL_MODULE := org.lineageos.platform.sdk.aar

LOCAL_JACK_ENABLED := disabled

LOCAL_CONSUMER_PROGUARD_FILE := $(LOCAL_PATH)/sdk/proguard.txt

LOCAL_RESOURCE_DIR := $(addprefix $(LOCAL_PATH)/, sdk/res/res)
LOCAL_MANIFEST_FILE := sdk/AndroidManifest.xml

lineage_sdk_exclude_files := 'lineageos/library'
LOCAL_JAR_EXCLUDE_PACKAGES := $(lineage_sdk_exclude_files)
LOCAL_JAR_EXCLUDE_FILES := none

LOCAL_STATIC_JAVA_LIBRARIES := org.lineageos.platform.sdk

include $(BUILD_STATIC_JAVA_LIBRARY)
$(LOCAL_MODULE) : $(built_aar)

# full target for use by platform apps
#
include $(CLEAR_VARS)

LOCAL_MODULE:= org.lineageos.platform.internal
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := services

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(lineage_sdk_src)) \
    $(call all-java-files-under, $(lineage_sdk_internal_src)) \
    $(call all-Iaidl-files-under, $(lineage_sdk_src)) \
    $(call all-Iaidl-files-under, $(lineage_sdk_internal_src))

# Included aidl files from lineageos.app namespace
LOCAL_AIDL_INCLUDES := $(LOCAL_PATH)/sdk/src/java
LOCAL_AIDL_FLAGS := -n

lineage_sdk_LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_platform_res)/lineageos/platform/R.java \
    $(lineage_platform_res)/lineageos/platform/Manifest.java \
    $(lineage_platform_res)/org/lineageos/platform/internal/R.java \
    $(lineage_platform_res)/org/lineageos/platform/internal/Manifest.java

LOCAL_INTERMEDIATE_SOURCES := \
    $(lineage_sdk_LOCAL_INTERMEDIATE_SOURCES)

LOCAL_JAVA_LIBRARIES := \
    $(lineage_sdk_LOCAL_JAVA_LIBRARIES)

$(full_target): $(lineage_framework_built) $(gen)
include $(BUILD_STATIC_JAVA_LIBRARY)


# ===========================================================
# Common Droiddoc vars
lineage_platform_docs_src_files := \
    $(call all-java-files-under, $(lineage_sdk_src)) \
    $(call all-html-files-under, $(lineage_sdk_src))

lineage_platform_docs_java_libraries := \
    org.lineageos.platform.sdk

# SDK version as defined
lineage_platform_docs_SDK_VERSION := 15.1

# release version
lineage_platform_docs_SDK_REL_ID := 8

lineage_platform_docs_LOCAL_MODULE_CLASS := JAVA_LIBRARIES

lineage_platform_docs_LOCAL_DROIDDOC_SOURCE_PATH := \
    $(lineage_platform_docs_src_files)

intermediates.COMMON := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),org.lineageos.platform.sdk,,COMMON)

# ====  the api stubs and current.xml ===========================
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    $(lineage_platform_docs_src_files)
LOCAL_INTERMEDIATE_SOURCES:= $(lineage_platform_LOCAL_INTERMEDIATE_SOURCES)
LOCAL_JAVA_LIBRARIES:= $(lineage_platform_docs_java_libraries)
LOCAL_MODULE_CLASS:= $(lineage_platform_docs_LOCAL_MODULE_CLASS)
LOCAL_DROIDDOC_SOURCE_PATH:= $(lineage_platform_docs_LOCAL_DROIDDOC_SOURCE_PATH)
LOCAL_ADDITIONAL_JAVA_DIR:= $(intermediates.COMMON)/src
LOCAL_ADDITIONAL_DEPENDENCIES:= $(lineage_platform_docs_LOCAL_ADDITIONAL_DEPENDENCIES)

LOCAL_MODULE := lineage-api-stubs

LOCAL_DROIDDOC_CUSTOM_TEMPLATE_DIR:= external/doclava/res/assets/templates-sdk

LOCAL_DROIDDOC_OPTIONS:= \
        -stubs $(TARGET_OUT_COMMON_INTERMEDIATES)/JAVA_LIBRARIES/lineage-sdk_stubs_current_intermediates/src \
        -stubpackages $(lineage_stub_packages) \
        -exclude org.lineageos.platform.internal \
        -api $(INTERNAL_LINEAGE_PLATFORM_API_FILE) \
        -removedApi $(INTERNAL_LINEAGE_PLATFORM_REMOVED_API_FILE) \
        -nodocs

LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_DROIDDOC)

# $(gen), i.e. framework.aidl, is also needed while building against the current stub.
$(full_target): $(lineage_framework_built) $(gen)
$(INTERNAL_LINEAGE_PLATFORM_API_FILE): $(full_target)
$(call dist-for-goals,sdk,$(INTERNAL_LINEAGE_PLATFORM_API_FILE))


# Documentation
# ===========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := org.lineageos.platform.sdk
LOCAL_INTERMEDIATE_SOURCES:= $(lineage_platform_LOCAL_INTERMEDIATE_SOURCES)
LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE_TAGS := optional

LOCAL_SRC_FILES := $(lineage_platform_docs_src_files)
LOCAL_ADDITONAL_JAVA_DIR := $(intermediates.COMMON)/src

LOCAL_IS_HOST_MODULE := false
LOCAL_DROIDDOC_CUSTOM_TEMPLATE_DIR := vendor/fh/build/tools/droiddoc/templates-lineage-sdk
LOCAL_ADDITIONAL_DEPENDENCIES := \
    services \
    org.lineageos.hardware

LOCAL_JAVA_LIBRARIES := $(lineage_platform_docs_java_libraries)

LOCAL_DROIDDOC_OPTIONS := \
        -offlinemode \
        -exclude org.lineageos.platform.internal \
        -hidePackage org.lineageos.platform.internal \
        -hdf android.whichdoc offline \
        -hdf sdk.version $(lineage_platform_docs_docs_SDK_VERSION) \
        -hdf sdk.rel.id $(lineage_platform_docs_docs_SDK_REL_ID) \
        -hdf sdk.preview 0 \
        -since $(LINEAGE_SRC_API_DIR)/1.txt 1 \
        -since $(LINEAGE_SRC_API_DIR)/2.txt 2 \
        -since $(LINEAGE_SRC_API_DIR)/3.txt 3 \
        -since $(LINEAGE_SRC_API_DIR)/4.txt 4 \
        -since $(LINEAGE_SRC_API_DIR)/5.txt 5 \
        -since $(LINEAGE_SRC_API_DIR)/6.txt 6 \
        -since $(LINEAGE_SRC_API_DIR)/7.txt 7 \
        -since $(LINEAGE_SRC_API_DIR)/8.txt 8

$(full_target): $(lineage_framework_built) $(gen)
include $(BUILD_DROIDDOC)

include $(call first-makefiles-under,$(LOCAL_PATH))

# Cleanup temp vars
# ===========================================================
lineage_platform_docs_src_files :=
lineage_platform_docs_java_libraries :=
intermediates.COMMON :=
