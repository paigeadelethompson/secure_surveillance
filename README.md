# Secure Surveillance System 
Based around Raspberry Pi 3/4/5 / EasyCap USB. 

Parts list: https://www.amazon.com/hz/wishlist/ls/50G0MY6VFOCH?ref_=wl_share

## Installation (Raspi)

- Download zip from releases page; minimum ~8GB micro SDHC card required
- `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`

### Extend the storage / home directory partition 
- Edit the card with parted, delete partition 3 and recreate it with the desired extents, specify that it is an NTFS partition.
- Do not format this partition, once the partition table is recreated simply mount the partition as if it were already formatted to test:
- TODO fsck?? 
```
root@xps-9310:/# parted /dev/mmcblk0
GNU Parted 3.5
Using /dev/mmcblk0
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) p                                                                
Model: SD SD16G (sd/mmc)
Disk /dev/mmcblk0: 7994MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  256MB   255MB   primary  fat32        boot, lba
 2      256MB   3128MB  2872MB  primary  ext4
 3      3128MB  7500MB  4373MB  primary

(parted) rm 3                                                             
(parted) mkpart                                                           
Partition type?  primary/extended? primary                                
File system type?  [ext2]? ntfs
Start? 3128                                                               
End? -1
(parted) p                                                                
Model: SD SD16G (sd/mmc)
Disk /dev/mmcblk0: 7994MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  256MB   255MB   primary  fat32        boot, lba
 2      256MB   3128MB  2872MB  primary  ext4
 3      3128MB  7993MB  4865MB  primary

                                                                   
(parted) quit
Information: You may need to update /etc/fstab.
# fsck.exfat /dev/mmcblk0p3 
exfatprogs version : 1.2.0
/dev/mmcblk0p3: clean. directories 6, files 2
# mount /dev/mmcblk0p3 /mnt
# tree /mnt
/mnt
├── motion_cam
├── motion_cameras
├── motion_logs
│   └── motion.log
├── motion_video
└── ssh
    └── authorized_keys

6 directories, 2 files
# mount | grep /mnt
/dev/mmcblk0p3 on /mnt type exfat (rw,relatime,fmask=0022,dmask=0022,iocharset=utf8,errors=remount-ro)
```

This partition is exfat (FAT64) and is accessible from Windows and MacOS computers. Unlike FAT32, ExFAT is not limited to 32GB, which ultimately will be ideal for video recording and retention.

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
