#!/bin/bash

#PIT 0x4400
#x-loader (MLO) 0x20000
#u-boot (Sbl.bin) 0x1800000
#boot.img 0x2400000
#recovery.img 0x2C00000

SBL="../../espresso-sbl/Sbl_uart_external_boot/Sbl.bin"
REC="../../OMAPFlash/for_P5113/recovery.img" # stuck on charge symbol
#REC="../../firmware/P5100XXDMI1_P5100XSADMI1_XSA/Firmware/unpacked/recovery.img"
#BOO="../../firmware/P5100XXDMI1_P5100XSADMI1_XSA/Firmware/unpacked/boot.img"
BOO="$REC"

OUT="debrick_own.img"

# base our image on the dumped 'original'
cp "backup of first 36MiB.img" "$OUT"

dd if="$SBL" of="$OUT" seek=$((0x1800000)) oflag=seek_bytes conv=notrunc
dd if="$REC" of="$OUT" seek=$((0x2C00000)) oflag=seek_bytes conv=notrunc
dd if="$BOO" of="$OUT" seek=$((0x2400000)) oflag=seek_bytes conv=notrunc
