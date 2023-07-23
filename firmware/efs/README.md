
# Getting EFS from a eMMC backup

The EFS partition resides from sector 8192 to sector 49151.

	dd if=backup\ of\ first\ 36MiB.img \
		  of=efs.img \
		  skip=$((512 * 8192)) \
		  bs=512 \
		  count=$((49151 - 8192 + 1)) \
		  iflag=skip_bytes

The image can then be mounted:

	sudo mount -o loop efs.img mount_dir

# EFS structure

EFS is an ext4 partition. The files on this partition are:

	./wifi
	./wifi/.mac.info
	./.files
	./.files/.dx1
	./.files/.dm33
	./.files/.mp301
	./FactoryApp
	./FactoryApp/test_nv
	./FactoryApp/hist_nv
	./FactoryApp/fdata
	./FactoryApp/serial_no
	./FactoryApp/factorymode
	./FactoryApp/keystr
	./FactoryApp/hw_ver
	./FactoryApp/baro_delta
	./FactoryApp/prepay
	./FactoryApp/earjack_count
	./FactoryApp/batt_cable_count
	./uart.txt
	./bluetooth
	./bluetooth/bt_addr
	./imei
	./imei/mps_code.dat
	./imei/prodcode.dat
	./redata.bin
	./wv.keys
	./h2k.dat
	./carrier
	./carrier/HiddenMenu

Most of the files in there are ASCII files:

	./wifi/.mac.info: ASCII text, with no line terminators
	./FactoryApp/test_nv: ASCII text, with no line terminators
	./FactoryApp/hist_nv: empty
	./FactoryApp/fdata: ASCII text, with no line terminators
	./FactoryApp/serial_no: ASCII text, with no line terminators
	./FactoryApp/factorymode: ASCII text, with no line terminators
	./FactoryApp/keystr: ASCII text, with no line terminators
	./FactoryApp/hw_ver: ASCII text, with no line terminators
	./FactoryApp/baro_delta: very short file (no magic)
	./FactoryApp/prepay: ASCII text, with no line terminators
	./FactoryApp/earjack_count: ASCII text, with no line terminators
	./FactoryApp/batt_cable_count: ASCII text
	./uart.txt: ASCII text, with no line terminators
	./bluetooth/bt_addr: ASCII text, with no line terminators
	./imei/mps_code.dat: ASCII text, with no line terminators
	./imei/prodcode.dat: ASCII text, with no line terminators
	./redata.bin: data
	./wv.keys: data
	./h2k.dat: data
	./carrier/HiddenMenu: ASCII text, with no line terminators

So the only 'problematic' files which we cannot re-create easily would then be:

1. redata.bin
2. wv.keys
3. h2k.dat

Regarding the `.files` "files": no clue what they do, let's hope they're not
necessary.


