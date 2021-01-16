# Device Tree for OnePlus 7T Pro aka Hotdog for TWRP
## Disclaimer
These are personal test builds of mine. In no way do I hold responsibility if it/you messes up your device.
Proceed at your own risk.

## Setup repo tool
Setup repo tool from here https://source.android.com/setup/build/downloading

## Compile

First sync twrp-10.0 manifest:

```
repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0
```

Now add this to .repo/manifests/twrp-extras.xml

```xml
<project name="systemad/android_device_oneplus_hotdog" path="device/oneplus/hotdog" remote="github" revision="android-10" />
```

Sync the sources with

```
repo sync
```

To build, execute these commands in order

```
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
lunch omni_hotdog-eng 
mka adbd recoveryimage 
```

To test it:

```
fastboot boot out/target/product/hotdog/recovery.img
```
Credit: Captain Throwback for original trees.
