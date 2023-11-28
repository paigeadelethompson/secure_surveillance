# Secure Surveillance System 
Based around Raspberry Pi 3/4/5 / EasyCap USB. 

Equipment list: https://www.amazon.com/hz/wishlist/ls/50G0MY6VFOCH?ref_=wl_share

This list is fairly curated but you're welcome to shop around. This is a recipe for probably the best kind of surveillance system you can get and it will work well, but there are some things worth understanding about it which could be a nightmare for certain people. In a pinch I could support this for a client no problem. Admittedly there's a lot to be said for low voltage tech and just making Linux work correctly and it's not always trivial. This is here for anybody 
that can appreciate it, with no gurantees except for what you can gurantee yourself.

This operating system image is produced entirely using a Github Workflow, if I can't maintain this then surely somebody else can.

## Installation (Raspi)

- Download zip from releases page; minimum ~8GB micro SDHC card required
- `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`

### Extend the storage / home directory partition (Use as large of an SD card as you want)
- Edit the card with parted, delete partition 3 and recreate it with the desired extents, specify that it is an NTFS partition.
- Do not format this partition, once the partition table is recreated simply mount the partition as if it were already formatted to test:
  
```
# parted /dev/mmcblk0
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

This partition is exfat (FAT64) and is accessible from Windows and MacOS computers. Unlike FAT32, ExFAT is not limited to 32GB, which ultimately will be ideal for video recording and retention. One other caveat is that ExFAT like FAT32 has a very rudimentary file attribute label, so to work around this the filesystem is
mounted with virtual attributes by the OS at boot:

```
/dev/mmcblk0p3 /home/pi exfat defaults,nofail,uid=4000,gid=5000,dmask=007,fmask=117 0 0
```

And all services which need read/write access to the storage FS are to be a member of the `pi` group. 

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

# Configuration
Network configuration can be specified in cmdline.txt:

```
ip=192.168.180.120:192.168.180.100:192.168.180.1:255.255.255.0::enp1s0:off
```

However systemd-networkd is configured to lease from DHCP or self-assign and should even be reachable by self assigned address if mDNS is available.

The cmdline.txt and authorized_keys (SSH) file live on separate partitions but both partitions are accessible from a Windows, MacOS, or Linux system. An SSH key 
is required for access and will need to be configured.

## TODO 
- OS boots, on QEMU and on a Raspi 3, this system needs to be put to the test and camera configuration is incomplete.
