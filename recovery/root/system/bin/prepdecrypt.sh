#!/sbin/sh

SCRIPTNAME="PrepDecrypt"
LOGFILE=/tmp/recovery.log
venbin="/vendor/bin"
venlib="/vendor/lib"
DEFAULTPROP=prop.default

log_info()
{
	echo "I:$SCRIPTNAME:$1" >> "$LOGFILE"
}

log_error()
{
	echo "E:$SCRIPTNAME:$1" >> "$LOGFILE"
}

relink()
{
	log_info "Looking for $1 to update linker path..."
	if [ -f "$1" ]; then
		fname=$(basename "$1")
		target="/sbin/$fname"
		log_info "File found! Relinking $1 to $target..."
		sed 's|/system/bin/linker|///////sbin/linker|' "$1" > "$target"
		chmod 755 "$target"
	else
		log_info "File not found. Proceeding without relinking..."
	fi
}

finish()
{
	setprop crypto.ready 1
	log_info "crypto.ready=$(getprop crypto.ready)"
	log_info "Script complete. Device ready for decryption."
	exit 0
}

log_info "Running $SCRIPTNAME script for TWRP..."

abi=$(getprop ro.product.cpu.abi)
osver=$(getprop ro.build.version.release)
osver_orig=$(getprop ro.build.version.release_orig)
sdkver=$(getprop ro.build.version.sdk)
patchlevel=$(getprop ro.build.version.security_patch)
patchlevel_orig=$(getprop ro.build.version.security_patch_orig)

case "$abi" in
	*64*)
		venlib="/vendor/lib64"
		;;
esac

log_info "SDK version: $sdkver"
if [ "$sdkver" -lt 26 ]; then
	DEFAULTPROP=default.prop
	log_info "Legacy device found! DEFAULTPROP variable set to $DEFAULTPROP."
fi
if [ "$sdkver" -lt 29 ]; then
	relink "$venbin/qseecomd"
	relink "$venbin/hw/android.hardware.keymaster@3.0-service"
	relink "$venbin/hw/android.hardware.keymaster@3.0-service-qti"
	relink "$venbin/hw/android.hardware.keymaster@4.0-service"
	relink "$venbin/hw/android.hardware.keymaster@4.0-service-qti"
	relink "$venlib/libQSEEComAPI.so"
	if [ -f /init.recovery.qcom_decrypt.fbe.rc ]; then
		log_info "FBE device detected! Performing additional relinking..."
		relink "$venbin/hw/android.hardware.gatekeeper@1.0-service"
		relink "$venbin/hw/android.hardware.gatekeeper@1.0-service-qti"
	fi
fi

# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
if [ -z "$osver" ]; then
	log_info "ro.build.version.release=$osver"
	log_error "No OS version found. Checking original props..."
	if [ -n "$osver_orig" ]; then
		log_info "Original OS version found. ro.build.version.release_orig=$osver_orig"
		log_info "Settings OS version to original value..."
		setprop ro.build.version.release "$osver_orig"
		log_info "OS version set. ro.build.version.release=$osver"
		log_info "Updating $DEFAULTPROP with Original OS version..."
		echo "ro.build.version.release=$osver_orig" >> "/$DEFAULTPROP";
		osver_default=$(grep ro.build.version.release /$DEFAULTPROP)
		log_info "$DEFAULTPROP updated. $osver_default"
	else
		log_error "No Original OS version found. Setting default value..."
		osver="16.1.0"
		setprop ro.build.version.release "$osver"
		log_info "OS version set. ro.build.version.release=$osver"
		log_info "Updating $DEFAULTPROP with default OS version..."
		echo "ro.build.version.release=$osver" >> "/$DEFAULTPROP";
		osver_default=$(grep ro.build.version.release /$DEFAULTPROP)
		log_info "$DEFAULTPROP updated. $osver_default"
	fi
else
	log_info "OS version exists! ro.build.version.release=$osver"
	osver_default=$(grep ro.build.version.release /$DEFAULTPROP)
	log_info "$DEFAULTPROP value: $osver_default"
fi
if [ -z "$patchlevel" ]; then
	log_info "ro.build.version.security_patch=$patchlevel"
	log_error "No Security Patch Level found. Checking original props..."
	if [ -n "$patchlevel_orig" ]; then
		log_info "Original Security Patch Level found. ro.build.version.security_patch_orig=$patchlevel_orig"
		log_info "Settings Security Patch Level to original value..."
		setprop ro.build.version.security_patch "$patchlevel_orig"
		log_info "Security Patch Level set. ro.build.version.security_patch=$patchlevel"
		log_info "Updating $DEFAULTPROP with Original Security Patch Level..."
		echo "ro.build.version.security_patch=$patchlevel_orig" >> "/$DEFAULTPROP";
		patchlevel_default=$(grep ro.build.version.security_patch /$DEFAULTPROP)
		log_info "$DEFAULTPROP updated. $patchlevel_default"
		finish
	else
		log_error "No Original Security Patch Level found. Setting default value..."
		patchlevel="2099-12-31"
		setprop ro.build.version.security_patch "$patchlevel"
		log_info "Security Patch Level set. ro.build.version.security_patch=$patchlevel"
		log_info "Updating $DEFAULTPROP with default Security Patch Level..."
		echo "ro.build.version.security_patch=$patchlevel" >> "/$DEFAULTPROP";
		patchlevel_default=$(grep ro.build.version.security_patch /$DEFAULTPROP)
		log_info "$DEFAULTPROP updated. $patchlevel_default"
		finish
	fi
else
	log_info "Security Patch Level exists! ro.build.version.security_patch=$patchlevel"
	patchlevel_default=$(grep ro.build.version.security_patch /$DEFAULTPROP)
	log_info "$DEFAULTPROP value: $patchlevel_default"
	finish
fi
