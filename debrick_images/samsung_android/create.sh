#!/bin/bash

set -eu
set -o pipefail

# info: sector size is 512 byte

# Partition table:
# Number  Start (sector)    End (sector)  Size       Code  Name
#    1            8192           49151   20.0 MiB    0700  EFS
#    2           49152           53247   2.0 MiB     0700  SBL1
#    3           53248           57343   2.0 MiB     0700  SBL2
#    4           57344           73727   8.0 MiB     0700  PARAM
#    5           73728           90111   8.0 MiB     0700  KERNEL
#    6           90112          106495   8.0 MiB     0700  RECOVERY
#    7          106496         1540095   700.0 MiB   0700  CACHE
#    8         1540096         1581055   20.0 MiB    0700  MODEM
#    9         1581056         4448255   1.4 GiB     0700  FACTORYFS
#   10         4448256        29728733   12.1 GiB    0700  DATAFS
#   11        29728734        30777309   512.0 MiB   0700  HIDDEN

# There are noteworthy locations that are not explicit but used
# internally, e.g.:
#    1              34              41   4.0 KiB     8300  PIT
#    2              42             255   107.0 KiB   8300  GANG
#    3             256             511   128.0 KiB   8300  MLO1
#    4             512             767   128.0 KiB   8300  MLO2
#    5             768             768   512 bytes   8300

# Necessary payloads in memory (not necessarily aligned with partition table):
# PIT 0x4400
# x-loader (MLO) 0x20000
# u-boot (Sbl.bin) 0x1800000
# boot.img 0x2400000
# recovery.img 0x2C00000

MLO="../../firmware/GT-P5100_DBT_1/bootloader/MLO"
SBL="../../firmware/espresso-sbl/Sbl_uart_external_boot/Sbl.bin"
REC="../../firmware/GT-P5100_DBT_1/platform/recovery.img"
PIT="../../firmware/pit/GTab2 P5100 16G.pit"
BOO="../../firmware/GT-P5100_DBT_1/platform/boot.img"
CAC="../../firmware/GT-P5100_DBT_1/csc/cache_unsparse.img"
MOD="../../firmware/GT-P5100_DBT_1/modem/modem.bin"
FFS="../../firmware/GT-P5100_DBT_1/platform/system_unsparse.img"
DAT="../../firmware/GT-P5100_DBT_1/platform/userdata_unsparse.img"
HID="../../firmware/GT-P5100_DBT_1/csc/hidden_unsparse.img"

OUT="debrick_own.img"

is_android_sparse_image() {
	file "$1" | grep -q 'Android sparse image';
	return $?
}

fail_if_sparse() {
	# Many dumps are saved in the Android sparse image format. This image
	# is not suitable to be written with dd and needs to be un-sparse-ified
	# before. This can be done with the simg2img tool.
	# (https://github.com/anestisb/android-simg2img)
	if is_android_sparse_image "$1"; then
		echo "Error: Convert $1 to plain image using simg2img before!"
		exit 1
	fi
}

fail_if_sparse "$FFS"
fail_if_sparse "$DAT"
fail_if_sparse "$CAC"
fail_if_sparse "$HID"

if [ -e "$OUT" ]; then
	rm "$OUT"
fi

# allocate space sparsely to work on
truncate -s 16GiB "$OUT"

# create partition table
parted "$OUT" mklabel gpt
sgdisk -a 1 \
       -n  1:8192:49151        -t  1:0700 -c  1:EFS  \
       -n  2:49152:53247       -t  2:0700 -c  2:SBL1  \
       -n  3:53248:57343       -t  3:0700 -c  3:SBL2  \
       -n  4:57344:73727       -t  4:0700 -c  4:PARAM  \
       -n  5:73728:90111       -t  5:0700 -c  5:KERNEL  \
       -n  6:90112:106495      -t  6:0700 -c  6:RECOVERY  \
       -n  7:106496:1540095    -t  7:0700 -c  7:CACHE  \
       -n  8:1540096:1581055   -t  8:0700 -c  8:MODEM  \
       -n  9:1581056:4448255   -t  9:0700 -c  9:FACTORYFS  \
       -n 10:4448256:29728733  -t 10:0700 -c 10:DATAFS  \
       -n 11:29728734:30777309 -t 11:0700 -c 11:HIDDEN \
	   "$OUT"

# write payloads
dd if="$MLO" of="$OUT" seek=$((0x20000)) oflag=seek_bytes conv=notrunc
dd if="$PIT" of="$OUT" seek=$((0x4400)) oflag=seek_bytes conv=notrunc
dd if="$SBL" of="$OUT" seek=$((0x1800000)) oflag=seek_bytes conv=notrunc
dd if="$REC" of="$OUT" seek=$((0x2C00000)) oflag=seek_bytes conv=notrunc
dd if="$BOO" of="$OUT" seek=$((0x2400000)) oflag=seek_bytes conv=notrunc
dd if="$CAC" of="$OUT" seek=$((106496 * 512)) oflag=seek_bytes conv=notrunc
dd if="$MOD" of="$OUT" seek=$((1540096 * 512)) oflag=seek_bytes conv=notrunc
dd if="$FFS" of="$OUT" seek=$((1581056 * 512)) oflag=seek_bytes conv=notrunc
dd if="$DAT" of="$OUT" seek=$((4448256 * 512)) oflag=seek_bytes conv=notrunc
dd if="$HID" of="$OUT" seek=$((29728734 * 512)) oflag=seek_bytes conv=notrunc
