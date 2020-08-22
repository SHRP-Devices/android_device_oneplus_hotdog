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

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_minimal.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from hardware-specific part of the product configuration
$(call inherit-product, device/asus/$(PRODUCT_RELEASE_NAME)/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := I003D
PRODUCT_NAME := omni_I003D
PRODUCT_BRAND := asus
PRODUCT_MODEL := ASUS_I003D
PRODUCT_MANUFACTURER := asus

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=WW_I003D \
    BUILD_PRODUCT=ZS661KS \
    TARGET_DEVICE=ASUS_I003_1

PRODUCT_EXTRA_RECOVERY_KEYS += device/$(PRODUCT_BRAND)/$(PRODUCT_DEVICE)/security/$(PRODUCT_BRAND)

# Verity
PRODUCT_SUPPORTS_BOOT_SIGNER := true
PRODUCT_SUPPORTS_VERITY := true
PRODUCT_SUPPORTS_VERITY_FEC := true
PRODUCT_VERITY_SIGNING_KEY := build/target/product/security/verity
