
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

# EFS ext4 partition

Output of `tune2fs -l`:

```
tune2fs 1.46.5 (30-Dec-2021)
Filesystem volume name:   <none>
[...]
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal resize_inode filetype extent sparse_super large_file
Filesystem flags:         unsigned_directory_hash
Default mount options:    (none)
Filesystem state:         clean
Errors behavior:          Panic
Filesystem OS type:       Linux
Inode count:              1280
Block count:              5120
Reserved block count:     0
Free blocks:              3975
Free inodes:              1241
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      7
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         1280
Inode blocks per group:   80
Last mount time:          Sun Jul 23 20:11:47 2023
Last write time:          Sun Jul 23 21:19:38 2023
Mount count:              213
Maximum mount count:      -1
Last checked:             Thu Jan  1 01:00:00 1970
Check interval:           0 (<none>)
Lifetime writes:          305 MB
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:	          256
Required extra isize:     28
Desired extra isize:      28
Journal inode:            8
Default directory hash:   tea
Journal backup:           inode blocks
```


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


