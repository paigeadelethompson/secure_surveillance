# Secure Surveillance System 
Based around Raspberry Pi 3/4/5 / EasyCap USB. 

Parts list: https://www.amazon.com/hz/wishlist/ls/50G0MY6VFOCH?ref_=wl_share

## Installation (Raspi)

- Download zip from releases page, requires one 32GB micro SDXC card
- `dd if=installer.bin of=/dev/mmcblk0 bs=1M`


# Testing with QEmu 

- Get the kernel 

```
losetup -P /dev/loop254 installer.bin
mount /dev/loop254p1 /mnt
mkdir krn/ ; cp /mnt/* krn/
umount /mnt
losetup -D /dev/loop254
```

- Start QEmu 

```
qemu-system-aarch64                                                                                                                        \
-M raspi3b                                                                                                                                 \
-kernel krn/kernel8.img                                                                                                                    \
-dtb krn/bcm2710-rpi-3-b.dtb                                                                                                               \
-drive format=raw,file=installer.bin                                                                                                       \
-append "root=/dev/mmcblk0p2 rootfstype=ext4 rootwait console=ttyAMA1,115200 console=tty1 fsck.repair=yes net.ifnames=0 elevator=deadline" \
-netdev user,id=net0,net=169.254.0.0/16,dhcpstart=169.254.0.2,hostfwd=tcp::2222-:22                                                        \
-device usb-net,netdev=net0                                                                                                                \
-device usb-kbd
```
