#
# Copyright 2017 The Android Open Source Project
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
#

# Release name
PRODUCT_RELEASE_NAME := I003D

$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from hardware-specific part of the product configuration
$(call inherit-product, device/asus/$(PRODUCT_RELEASE_NAME)/device.mk)

# System & Vendor Properties
PRODUCT_SYSTEM_DEVICE := ASUS_I003_1
PRODUCT_SYSTEM_NAME := WW_$(PRODUCT_RELEASE_NAME)
PRODUCT_VENDOR_DEVICE := $(PRODUCT_SYSTEM_DEVICE)
PRODUCT_VENDOR_NAME := $(PRODUCT_SYSTEM_NAME)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := $(PRODUCT_RELEASE_NAME)
PRODUCT_NAME := omni_$(PRODUCT_DEVICE)
PRODUCT_BRAND := asus
PRODUCT_MODEL := ASUS_$(PRODUCT_DEVICE)
PRODUCT_MANUFACTURER := asus

# Overrides
PRODUCT_BUILD_PROP_OVERRIDES += \
   BUILD_PRODUCT=ZS661KS \
   PRODUCT_DEVICE=$(PRODUCT_SYSTEM_DEVICE) \
   PRODUCT_NAME=$(PRODUCT_SYSTEM_NAME)

# Stock recovery keys
PRODUCT_EXTRA_RECOVERY_KEYS += device/$(PRODUCT_BRAND)/$(PRODUCT_DEVICE)/security/$(PRODUCT_BRAND)
