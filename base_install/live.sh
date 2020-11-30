### sync time
# timedatectl set-ntp true

### disk partition
# fdisk -l
# fdisk /dev/sda

### make filesystem
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3

### mount filesystem to the live image i.e. the live environment we are now running
mount /dev/sda3 /mnt

### install the base system for arch
pacstrap /mnt base linux linux-firmware

### generate an fstab  -> filesystem table
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

