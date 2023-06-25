# Creating the image

Make sure you have the correct files needed to create this image.

The script needs the following payloads and expects them in the paths
noted in parenthesis.

- MLO (`../../firmware/GT-P5100_DBT_1/MLO`)
- SBL (`../../firmware/espresso-sbl/Sbl_uart_external_boot/Sbl.bin`)
- Recovery (`../../firmware/GT-P5100_DBT_1/platform/recovery.img`)
- PIT (`../../firmware/pit/GTab2 P5100 16G.pit`)

If all files are present, you can execute the script

	bash ./create.sh

# Writing to SD

	sudo dd if=debrick_own.img of=/dev/sdb bs=1M oflag=sync

# Testing

- sd card inserted
- `omapboot.py -b` started
- plug cable in
- optionally: power on device (if not already on / boot looping)

