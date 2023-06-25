# Creating the image

Make sure you have the correct files needed to create this image.


	./create.sh

# Writing to SD

	sudo dd if=debrick_own.img of=/dev/sdb bs=1M oflag=sync

# Testing

- battery unplugged
- sd card inserted
- `omapboot.py -b` started
- plug cable in

# Sources

## Files

- PIT files are from [here][pit1]
- OMAPFlash for MLO and recovery image [here](https://forum.xda-developers.com/t/guide-gt-i9100g-repair-totally-sleep-dead-boot-mode-via-usb.1701471/post-35127581)
