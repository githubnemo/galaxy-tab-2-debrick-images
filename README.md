
# Dealing with low battery

The boot loader has a cutoff voltage of 3.45V - if the battery is below that
voltage the boot process will reboot before loading the kernel or recovery.
While boot-looping the battery will charge, albeit slowly. Once the threshold
is crossed, the boot process continues but the charging voltage does not
increase, i.e. if your device is stuck and the display turns on it will
decharge and you're stuck in a boot-loop again soon enough.

If connected to an UART-connector you can interrupt the boot process (hit
enter when prompted with the auto-timeout). You will drop into the boot loader
shell and when entering 'usb' you will be in ODIN download mode. Pressing
volume-down will turn off the device but it will continue to charge.

# Terminology

When reading this you will stumble upon various terms that might you
might raise your eyebrows on. I will try to list and explain them in this
section.

## PIT

The PIT is the partition table of the internal flash (eMMC). If you would be
able to mount the eMMC in your local system, you would see ~12 partitions.  It
is also a file that is present on the eMMC for reasons I don't know but I
suspect that one of the boot loaders (MLO, Sbl or potentially something
different) need this to refer to partitions without understanding the
partition table of the storage device itself.

These files are often called `<make> <model> <size>.pit`, e.g.
`GTab2 P5100 16G.pit` and are, sadly, seldomly included in firmware dumps.

You can find a 16GB PIT in the `pit` folder.


# Goals

I have a bricked GT-P5100 with a likely eMMC fault and I want to revive this
device. If possible, I just want to re-flash the eMMC and everything's fine
(getting the device into ODIN mode is the goal here). If that's not an option
because the eMMC is bad, I want to be able to boot everything from SD-card
(creating a bootable SD-card firmware image from scratch is the goal).

## Get the device into ODIN mode

### With UART adapter

Needed:

- working UART cable + serial USB adapter
- minimal sd card image with
	* MLO
	* Sbl
	* partition table (on disk as data and applied to the image)

The script to create such an image can be found in
`./debrick_images/minimal_uart`.

### Without UART adapter

Needed:

- working USB cable for the Galaxy Tab
- recovery df card image with
	* MLO
	* Sbl
	* partition table (on disk as data and applied to the image)
	* optional: recovery image

The script to create such an image can be found in
`./debrick_images/minimal_recovery`.

The process to get here is a bit more involved due to a bug I don't really
understand. In essence: You need to unplug the USB cable in the right moment
to transfer the payload to boot from SD card but not to land in the 'charger'
payload which hangs since it cannot access the eMMC.

1. Flash the SD card with the image of `./debrick_images/minimal_uart`
   `dd if=img of=<sd card> bs=1M oflag=sync`
2. Start `omapboot.py -b`
3. Press Vol Up + Power on the tablet (shortcut for ODIN mode)
4. Plug in USB cable
5. Wait for `omapboot` to show `Giving x-loader a chance to come up..`
	(~two dots are enough wait)
6. Unplug USB cable
7. Wait until Samsung Galaxy boot logo and (a bit after that) ODIN mode
   appears on the screen

The same process can be done without the key combination to enter the recovery
image since the `minimal_uart` SD card image sets the recovery image as its
boot payload. From the recovery you can connect via `adb` and explore the
system. For me the eMMC was not listed as a block device, suggesting that it
was not even initializing properly anymore. In that case the device can only
be used with external SD card.

## Create a sd-card bootable firmware image from scratch

TODO

# UART adapter

Pins 20 (RX) and 21 (TX) of the dock connector are for serial (115200 baud 8n1)
communication. If you flash one of the Sbl UART boot loaders from
[here](https://github.com/mspitteler/espresso-sbl) you will see helpful
debugging messages on these pins.

Modifying old iPad connectors (peripheral connectors have all 30 pins available)
is a way to get these cables. The pinout for a USB + UART connector can be found
[here](./documents/pinout_usb_adapter.md).

TODO insert setup photo here


# Sources

## Documents

- [UART pinout](https://forum.xda-developers.com/t/samsung-galaxy-tab-30-pin-dock-connector-pinout.1118986/)

## Firmware

- [`GT-P5113_XAR_1_20131213093640_j4yd9st9cc_fac.zip`](https://sfirmware.com/downloads-file/24603/GT-P5113_XAR_1_20131213093640_j4yd9st9cc_fac)
- [`GT-P5100_DBT_1_20140813225430_nkfxle5pbd_fac.zip`](https://sfirmware.com/downloads-file/24553/GT-P5100_DBT_1_20140813225430_nkfxle5pbd_fac)
