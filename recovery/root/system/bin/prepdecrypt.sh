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

osver_default_value()
{
	osver_default=$(grep "$1" /$DEFAULTPROP)
	log_info "$DEFAULTPROP value: $osver_default"
}

patchlevel_default_value()
{
	patchlevel_default=$(grep "$1" /$DEFAULTPROP)
	log_info "$DEFAULTPROP value: $patchlevel_default"
	finish
}

update_default_values()
{
	if [ -z "$1" ]; then
		log_info "$4=$1"
		log_error "No $3. Checking original props..."
		if [ -n "$2" ]; then
			log_info "Original $3 found. $4_orig=$2"
			log_info "Setting $3 to original value..."
			setprop "$4" "$2"
			log_info "$3 set. $4=$1"
			log_info "Updating $DEFAULTPROP with Original $3..."
			echo "$4=$2" >> "/$DEFAULTPROP";
			$5 "$4"
		else
			log_error "No Original $3 found. Setting default value..."
			osver="16.1.0"
			patchlevel="2099-12-31"
			setprop "$4" "$1"
			log_info "$3 set. $4=$1"
			log_info "Updating $DEFAULTPROP with default $3..."
			echo "$4=$1" >> "/$DEFAULTPROP";
			$5 "$4"
		fi
	else
		log_info "$3 exists! $4=$1"
		$5 "$4"
	fi
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
update_default_values "$osver" "$osver_orig" "OS version" "ro.build.version.release" osver_default_value
update_default_values "$patchlevel" "$patchlevel_orig" "Security Patch Level" "ro.build.version.security_patch" patchlevel_default_value
