
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

## Info

- [basic eMMC offsets][emmc_offsets]
- [partition names and how ODIN uses them](https://android.stackexchange.com/questions/142420/what-does-the-rom-files-factoryfs-hidden-cache-param-etc-mean)

[pit1]: https://forum.xda-developers.com/t/pit-pit-files-for-all-samsung-tab-2-tablets-updated-op.2552155/post-48907965
[emmc_offsets]: https://forum.xda-developers.com/t/discussion-an-alternative-for-tab-2-emmc-bug-brick-backup.3306862/#post-65114419
