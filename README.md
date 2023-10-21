# Secure Surveillance System 
Based around Raspberry Pi 4 / EasyCap USB. 

Parts list: https://www.amazon.com/hz/wishlist/ls/50G0MY6VFOCH?ref_=wl_share

## Installation (RasPi4)

- Download zip from releases page, requires one 32GB micro SDXC card
- `dd if=installer.bin of=/dev/mmcblk0 bs=1M`


# Testing with QEmu 

Get the kernel 
```
losetup -P /dev/loop254 installer.bin
mount /dev/loop254p1 /mnt
mkdir krn/ ; cp /mnt/* krn/
umount /mnt
losetup -D /dev/loop254
```
Start QEmu 
`qemu-system-aarch64 -nographic -M raspi3b -kernel krn/kernel8.img -dtb stuff/bcm2710-rpi-3-b.dtb -drive format=raw,file=installer.bin -serial mon:stdio -append "console=ttyAMA1,115200n8 root=/dev/mmcblk0p2"`
