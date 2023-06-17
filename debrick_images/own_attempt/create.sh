#!/bin/bash

# info: sector size is 512 byte

#PIT 0x4400
#x-loader (MLO) 0x20000
#u-boot (Sbl.bin) 0x1800000
#boot.img 0x2400000
#recovery.img 0x2C00000

MLO="../../OMAPFlash/div. models/Targets/Projects/espresso/MLO"
SBL="../../espresso-sbl/Sbl_uart/Sbl.bin"
REC="../../OMAPFlash/for_P5113/recovery.img"
PIT="../../firmware/pit/GTab2 P5100 16G.pit"

OUT="debrick_own.img"
dd if="$MLO" of="$OUT" seek=$((0x20000)) oflag=seek_bytes conv=notrunc
dd if="$PIT" of="$OUT" seek=$((0x4400)) oflag=seek_bytes conv=notrunc
dd if="$SBL" of="$OUT" seek=$((0x1800000)) oflag=seek_bytes conv=notrunc
dd if="$REC" of="$OUT" seek=$((0x2C00000)) oflag=seek_bytes conv=notrunc

dd if="$REC" of="$OUT" seek=$((0x2400000)) oflag=seek_bytes conv=notrunc
