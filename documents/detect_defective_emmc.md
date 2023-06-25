

after upload of MLO/SBL and kernel:


```
==> Welcome to ESPRESSO_WIFI!
==> Entering usb download mode..
[usb] omap_usb_clock_setup : enable usb clock : 0x00000001
musb_init : OMAP4 :  High-Speed USB OTG Controller
Connected!!
 OK
tx_data=LOKE
process_packet: id=100, data=0
process_packet: id=100, data=5
packet data size changed. (131072 -> 1048576)
process_packet: id=100, data=2
process_packet: id=101, data=1
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=3
process_packet: id=102, data=0
process_packet: id=102, data=2
RX len : 1048576
........
process_packet: id=102, data=3
set_nps_update_start: set nps start flag successfully.
pda completed: id=1, size=262144, final=1
partition 1 verification failed.
partition 1 verification failed.
SECURE DOWNLOAD FAIL, ID 1
set_nps_update_completed: set nps completed flag successfully.
process_packet: id=103, data=0
set_nps_update_completed: set nps completed flag successfully.
movinand_checksum_pass succeed!
movinand_checksum_done succeed!
process_packet: id=103, data=1
```

only writing Sbl:

```
==> Welcome to ESPRESSO_WIFI!
==> Entering usb download mode..
[usb] omap_usb_clock_setup : enable usb clock : 0x00000001
musb_init : OMAP4 :  High-Speed USB OTG Controller
Connected!!
 OK
tx_data=LOKE
process_packet: id=100, data=0
process_packet: id=100, data=5
packet data size changed. (131072 -> 1048576)
process_packet: id=100, data=2
process_packet: id=101, data=1
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=2
process_packet: id=101, data=3
process_packet: id=102, data=0
process_packet: id=102, data=2
RX len : 1048576
........
RX len : 1048576
........
process_packet: id=102, data=3
set_nps_update_start: set nps start flag successfully.
pda completed: id=2, size=1310720, final=1
partition 2 verification failed.
SECURE DOWNLOAD FAIL, ID 2
set_nps_update_completed: set nps completed flag successfully.
process_packet: id=103, data=0
set_nps_update_completed: set nps completed flag successfully.
movinand_checksum_pass succeed!
movinand_checksum_done succeed!
process_packet: id=103, data=1
```
