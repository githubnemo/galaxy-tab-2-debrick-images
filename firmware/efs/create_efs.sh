#!/bin/bash

set -o pipefail
set -e
set -u

readonly efs_dir=$(mktemp -d)
readonly efs_mount=$(mktemp -d)
readonly efs_image="new_efs.img"

cleanup() {
	if [ -n "$efs_dir" ]; then
		echo "Cleaning up $efs_dir"
		sudo chown -R $(whoami) "$efs_dir"
		rm -r "$efs_dir"
	fi

	if [ -n "$efs_mount" ]; then
		echo "Cleaning up $efs_mount"
		if mount | grep -q "$efs_mount"; then
			sudo umount "$efs_mount"
		fi
		rmdir "$efs_mount"
	fi
}

trap cleanup EXIT

if [ -e "$efs_image" ]; then
	echo "Deleting previous EFS image."
	rm "$efs_image"
fi

# ----------------------------------------
# generate folder structure similar to EFS
# ----------------------------------------

echo "Generating EFS folders and files"

mkdir "$efs_dir/wifi"
mkdir "$efs_dir/FactoryApp"
mkdir "$efs_dir/bluetooth"
mkdir "$efs_dir/imei"
mkdir "$efs_dir/carrier"

random_samsung_mac() {
	random_hash=$(dd if=/dev/urandom count=10 bs=512 2>&1| sha256sum)
	random_octets=$(echo "$random_hash" | sed -e 's/\(..\)\(..\)\(..\)\(..\).*/\1:\2:\3:\4/')
	random_upper_octets=$(echo "$random_octets" | tr '[[:lower:]]' '[[:upper:]]')
	echo "6C:F3:$random_upper_octets"
}

# MAC addresses wifi + bluetooth
random_samsung_mac > "$efs_dir/wifi/.mac.info"
random_samsung_mac > "$efs_dir/bluetooth/bt_addr"

# FactoryApp
echo -n "01P02N03N04N05N06N07P08N09N10N11E12N13N14P15P16P17N18N19N20N21P22P23P24P25P26N27P28N29N30N31P32P33P34P35N36N37N38P39P40N41N42N43N44N45P46P47N48N49N50P51N52N53N54N55N56N57N58N59N60N61N62N63N64N65N66N67N68N69N70N71N72N73N74N75N76N77N78N79N80N81N82N83N84N85N86N87N88N89N90N" > "$efs_dir/FactoryApp/test_nv"
echo -n "" > "$efs_dir/FactoryApp/hist_nv"
echo -n "N0NN" > "$efs_dir/FactoryApp/fdata"
echo -n "RF2D30QG12P" > "$efs_dir/FactoryApp/serial_no"
echo -n "ON" > "$efs_dir/FactoryApp/factorymode"
echo -n "ON" > "$efs_dir/FactoryApp/keystr"
echo -n "MP 0.900" > "$efs_dir/FactoryApp/hw_ver"
echo -n "0" > "$efs_dir/FactoryApp/baro_delta"
echo -n "false" > "$efs_dir/FactoryApp/prepay"
echo -n "83" > "$efs_dir/FactoryApp/earjack_count"
echo -n "315" > "$efs_dir/FactoryApp/batt_cable_count"

# IMEI
echo -n "PHN" > "$efs_dir/imei/mps_code.dat"
echo -n "GT-P5110TSAPHN" > "$efs_dir/imei/prodcode.dat"

# UART
echo -n "AP" > "$efs_dir/uart.txt"

# carrier
echo -n "OFF" > "$efs_dir/carrier/HiddenMenu"

if [ -e "./local_keys.sh" ]; then
	source local_keys.sh
else
	echo "This repo does not include h2k.dat, redata.bin and wv.keys files "
	echo "as they probably include IMEI data. You need to create your own "
	echo "local_keys.sh file which writes these files or live with the empty "
	echo "default files created now."
	:> "$efs_dir/h2k.dat"
	:> "$efs_dir/redata.bin"
	:> "$efs_dir/wv.keys"
fi

# Set proper ownerships
echo "Seting proper ownerships"

sudo chown -R 1001:1000 "$efs_dir/bluetooth"
sudo chown 1001:1001 "$efs_dir/bluetooth/bt_addr"

sudo chown -R 1001:1000 "$efs_dir/wifi"
sudo chown 1000:1000 "$efs_dir/wifi/.mac.info"

sudo chown -R 1000:1000 "$efs_dir/carrier"

sudo chown -R 1001:1000 "$efs_dir/imei"
sudo chown 1001:1001 "$efs_dir/imei/mps_code.dat"
sudo chown 1001:1001 "$efs_dir/imei/prodcode.dat"

sudo chown -R 1000:1000 "$efs_dir/FactoryApp"
sudo chown 1000:1000 "$efs_dir/FactoryApp/baro_delta"
sudo chown 1000:1000 "$efs_dir/FactoryApp/batt_cable_count"
sudo chown 1013:1000 "$efs_dir/FactoryApp/earjack_count"
sudo chown 1000:1000 "$efs_dir/FactoryApp/factorymode"
sudo chown 1000:1001 "$efs_dir/FactoryApp/fdata"
sudo chown 1000:1001 "$efs_dir/FactoryApp/hist_nv"
sudo chown 1000:1000 "$efs_dir/FactoryApp/hw_ver"
sudo chown 1000:1000 "$efs_dir/FactoryApp/keystr"
sudo chown 1000:1000 "$efs_dir/FactoryApp/prepay"
sudo chown 1000:1000 "$efs_dir/FactoryApp/serial_no"
sudo chown 1000:1001 "$efs_dir/FactoryApp/test_nv"

sudo chown 1001:1001 "$efs_dir/uart.txt"
sudo chown 1001:1001 "$efs_dir/h2k.dat"
sudo chown 1001:1001 "$efs_dir/redata.bin"
sudo chown 1001:1001 "$efs_dir/wv.keys"

# ----------------------------------------
# generate a file system to put files into
# ----------------------------------------

echo "Creating image"

truncate -s 20M "$efs_image"
mkfs.ext4 -O '^huge_file,^metadata_csum,^extra_isize,^dir_nlink,^flex_bg,^dir_index,^ext_attr' "$efs_image"
tune2fs -o '^user_xattr,^acl' -E hash_alg=tea -e panic "$efs_image"

# Remove huge_file and 64 bit extension
resize2fs -s "$efs_image"
e2fsck -f "$efs_image"

sudo mount -o loop "$efs_image" "$efs_mount"

sudo tar -c -C "$efs_dir" . | sudo tar -x -C "$efs_mount"

echo "Everything done."
echo "EFS image: $efs_image"
