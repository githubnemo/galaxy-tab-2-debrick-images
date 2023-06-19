
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
	* partition table (on disk and applied)

The script to create such an image can be found in
`./debrick_images/minimal_uart`.

### Without UART adapter

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
