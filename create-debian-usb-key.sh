DIRNAME="$(dirname $0)"

DISK="$1"

EFI="${DISK}p1"
ROOT="${DISK}p2"
HOME="${DISK}p3"

parted ${DISK} mklabel gpt 
parted ${DISK} mkpart primary fat32 1 256
parted ${DISK} name 1 BOOT
parted ${DISK} mkpart primary ext2 256 3000
parted ${DISK} name 2 ROOT
parted ${DISK} mkpart primary fat32 3000 31950
parted ${DISK} name 3 HOME
parted ${DISK} set 1 boot on

echo "Creating a filesystem on ${EFI}"
mkfs.vfat -F32 "${EFI}"

echo "Creating a filesystem on ${ROOT}"
mkfs.ext4 "${ROOT}"

echo "Creating a filesystem on ${HOME}"
mkfs.vfat -F32 "${HOME}"

parted ${DISK} print

mkdir -p /mnt/
mount "${ROOT}" /mnt/
mkdir -p /mnt/boot
mount "${EFI}" /mnt/boot
mkdir -p /mnt/home/pi
mount "${HOME}" /mnt/home/pi
