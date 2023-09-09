DIRNAME="$(dirname $0)"

DISK="$1"
: "${DEBIAN_RELEASE:=stretch}"
: "${DEBIAN_VERSION:=9.2.1}"
: "${DEBIAN_MIRROR:=http://ftp.debian.org}"
: "${ARCH:=amd64}"
: "${REMOTE_ISO:=https://cdimage.debian.org/debian-cd/current/${ARCH}/iso-cd/debian-${DEBIAN_VERSION}-${ARCH}-netinst.iso}"
ISO_NAME="${REMOTE_ISO##*/}"

usage() {
  cat << EOF
Usage: $0 <disk> <iso>

disk     Disk to use (e.g. /dev/sdb) - will be wiped out

Overriding options via environment variables
DEBIAN_RELEASE  Release of Debian (default: buster)
DEBIAN_VERSION  VERSION of Debian (default: 9.2.1)
DEBIAN_MIRROR   Debian mirror (default: http://ftp.debian.org)
ARCH            Architecture (default: amd64)
EOF
}

[ $# -ne 1 ]     && echo "Please provide required args" && usage && exit 1
[ -z "${DISK}" ] && echo "Please provide a disk"        && usage && exit 1

EFI="${DISK}p1"
ROOT="${DISK}p2"
HOME="${DISK}p3"

parted ${DISK} mklabel gpt 
parted ${DISK} mkpart BOOT primary fat32 1 256
parted ${DISK} mkpart ROOT primary ext2 256 3000
parted ${DISK} mkpart HOME primary fat32 3000 4700
parted ${DISK} set 1 boot on

echo "Creating a filesystem on ${EFI}"
mkfs.vfat -F32 "${EFI}"

echo "Creating a filesystem on ${ROOT}"
mkfs.btrfs "${ROOT}"

echo "Creating a filesystem on ${HOME}"
mkfs.exfat "${HOME}"

parted ${DISK} print

mkdir -p /mnt/
mount "${ROOT}" /mnt/
mkdir -p /mnt/boot/efi
mount "${EFI}" /mnt/boot/efi
mkdir -p /mnt/home
mount "${HOME}" /mnt/home
