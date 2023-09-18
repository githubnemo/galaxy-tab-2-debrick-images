#!/bin/bash

set -eu
set -o pipefail

readonly tempdir="$(mktemp -d)"
readonly scriptdir="$(dirname "$(readlink -e "$0")")"


fake_image() {
	local name size caption
	output="$1"
	size="$2"
	caption="$3"


	convert -gravity center -background black -fill white \
		-size "$size" caption:"$caption" "$output"
	return $?
}

# Possible values:
# DLOW
# DMID
# DHIG
# DAUT
echo -n "DHIG" > "$tempdir/debug_level.inf"

echo "dummy" > "$tempdir/dummy.bin"
echo -n '\u0000' > "$tempdir/movinand_checksum_done"
echo -n '\u0000' > "$tempdir/movinand_checksum_pass"
echo -n 'COMP' > "$tempdir/nps_status"
:> "$tempdir/sw_sel"


fake_image "$tempdir/ani_upload_1_kernel_panic.jpg" 480x200 "Kernel Panic Upload Mode"
fake_image "$tempdir/ani_upload_2_cp_crash.jpg" 480x200 "CP Crash Upload Mode"
fake_image "$tempdir/ani_upload_3_forced_upload.jpg" 480x200 "Forced Upload by Key Pressing"
fake_image "$tempdir/ani_upload_4_hardware_reset.jpg" 480x200 "Hardware Reset"
fake_image "$tempdir/ani_upload_4_power_reset.jpg" 480x200 "Power Reset or Unknown Upload Mode"
fake_image "$tempdir/ani_upload_4_unknown_reset.jpg" 480x200 "Power Reset or Unknown Upload Mode"
fake_image "$tempdir/ani_upload_4_watchdog_reset.jpg" 480x200 "Watchdog Reset"
fake_image "$tempdir/ani_upload_5_user_fault.jpg" 480x200 "User Fault not Kernel Panic - Upload Mode"
fake_image "$tempdir/ani_upload_5_user_panic.jpg" 480x200 "User Panic Upload Mode"
fake_image "$tempdir/ani_upload_6_hsic_disconnected.jpg" 480x200 "HSIC Disconnected - Upload Mode"

fake_image "$tempdir/charging_10.jpg" 400x328 "Charging (Portrait)"
fake_image "$tempdir/charging_7.jpg" 262x320 "Charging (Landscape)"

fake_image "$tempdir/logo_espresso7.jpg" 140x470 "<insert vendor logo here> (landscape)"
fake_image "$tempdir/logo_espresso10.jpg" 695x110 "<insert vendor logo here> (portrait)"

fake_image "$tempdir/nps_fail.jpg" 405x275 "Firmware upgrade encountered an issue. Please select recovery mode in Kies & try again."
fake_image "$tempdir/nps_fail_chn.jpg" 405x275 "Firmware upgrade encountered an issue. Please select recovery mode in Kies & try again."

"$scriptdir"/../../tools/j4fs/j4fs.py \
	create -o "param.j4fs" -p 2048 -b 131072 "$tempdir"/*

echo "Created param.j4fs"
echo "Removing temporary $tempdir"
rm -r "$tempdir"
