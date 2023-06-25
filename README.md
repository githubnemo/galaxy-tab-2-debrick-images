
# Goals

I have a bricked GT-P5100 with a likely eMMC fault and I want to revive this
device. If possible, I just want to re-flash the eMMC and everything's fine
(getting the device into ODIN mode is the goal here). If that's not an option
because the eMMC is bad, I want to be able to boot everything from SD-card
(creating a bootable SD-card firmware image from scratch is the goal).

**Dependencies**: This work heavily depends on the great work done at
https://github.com/mspitteler/espresso-sbl to create a SBL that supports
booting from SD card. Also without the (modified) `omapboot` from
https://github.com/LukasTomek/omapboot all this would not work.

**Note:** if your device is low on battery you may experience issues when
booting. See [Dealing with low battery](#dealing-with-low-battery) for details.

## Get necessary files

This repo gives you scripts that create SD bootable images from firmware
images. You will need a bit of luck to get all the correct parts but the
[Firmware](./firmware) folder's README lists a few sources you can get started on.

See the specific debrick image script README files for details.

## Get the device into ODIN mode

### With UART adapter

Needed:

- `omapboot` tool downloaded
- working [UART adapter](#uart-adapter) + serial USB adapter
- minimal sd card image with
	* MLO
	* Sbl
	* partition table (on disk as data and applied to the image)

The script to create such an image can be found in
`./debrick_images/minimal_uart`.

To get into ODIN via UART you do the following:

1. Connect the tablet to your computer via USB, connect the USB-serial adapter
to the UART RX/TX lines
2. start a serial communication program such as `picocom`
3. insert SD card with image into tablet
4. start `omapboot.py -b`
5. Watch output in serial communication program - there should be a line
   saying `"Autoboot (1 seconds) in progress, press any key to stop ."` -
   press enter here, you will drop into a shell
6. Enter "usb" and press enter

Now the typical ODIN download screen should show up.

Here's a (shortened) example of the whole boot process:

```
Texas Instruments X-Loader 1.41 (Apr 16 2012 - 11:13:29)
Starting OS Bootloader from MMC/SD1 ...

...

Secondary Bootloader v3.1 version.
Copyright (C) 2011 System S/W Group. Samsung Electronics Co., Ltd.
Board: GT-P5110 REV 02-REAL / Dec 17 2013 00:27:05

booting code=0x93035e41
===== PARTITION INFORMATION =====
 ID         : X-loader (0x1)
 DEVICE     : MMC
 FIRST UNIT : 0
 NO. UNITS  : 0
...

Autoboot (1 seconds) in progress, press any key to stop .

Autoboot aborted..
SBL> usb

==> Welcome to ESPRESSO_WIFI!
==> Entering usb download mode..
...
```

### Without UART adapter

Needed:

- `omapboot` tool downloaded
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

## MLO

MLO, or x-loader in ODIN/Heimdall terminology, is the primary boot loader
and therefore critical to the boot process. It loads the Sbl.
It is signed by Samsung (citation needed) and not therefore not replaceable.

## Sbl

Means probably something like "Secondary boot loader". It is probably a
variant of [u-boot](https://github.com/u-boot/u-boot) and responsible for
loading the Linux kernel, the recovery or ODIN mode, depending on pressed
keys.

## PIT

The PIT is the partition table of the internal flash (eMMC). If you would be
able to mount the eMMC in your local system, you would see ~12 partitions.  It
is also a file that is present on the eMMC for reasons I don't know but I
suspect that one of the boot loaders (MLO, Sbl or potentially something
different) need this to refer to partitions without understanding the
partition table of the storage device itself.

These files are often called `<make> <model> <size>.pit`, e.g.
`GTab2 P5100 16G.pit` and are, sadly, seldomly included in firmware dumps.

You can find a 16GB PIT in the `firmware/pit` folder.

## UART

[Universal asynchronous receiver/transmitter](https://en.wikipedia.org/wiki/UART)
is a very common way to get debug information in the boot process of a device.
It usually features a receive (RX), transmit (TX) and ground (GND) line.
Sometimes, if the device is not powered on its own, also a voltage (VCC) line.
How to build an adapter so you can connect to the UART connection of the
Galaxy Tab 2 is documented in [UART Adapter](#uart-adapter).



# UART Adapter

Pins 20 (RX) and 21 (TX) of the dock connector ([source](https://forum.xda-developers.com/t/samsung-galaxy-tab-30-pin-dock-connector-pinout.1118986/))
are for serial (115200 baud 8n1) communication. If you flash one of the Sbl
UART boot loaders from [here](https://github.com/mspitteler/espresso-sbl) you
will see helpful debugging messages on these pins.

Modifying old iPad connectors (peripheral connectors have all 30 pins available)
is a way to get these cables. The pinout for a USB + UART connector can be found
[here](./documents/pinout_usb_adapter.md).

TODO insert setup photo here

To read the now available pins (RX/TX) you will need a USB to serial adapter
such as ones based on FT232R or simply an Arduino. If you don't know how
to do this, you will need to do your research but it is not complicated!

If you use a USB-serial adapter based on FT232R you can then use, for example,
`picocom` to read and write to the UART:

	picocom -b 115200 /dev/ttyUSB0
