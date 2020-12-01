# arch linux installation flow

### set keyboard
ls /usr/share/kbd/keymaps/**/*.map.gz
loadkeys de-lai**


### sync time
timedatectl set-ntp true


### disk partition
lsblk
fdisk -l

### disk partition
fdisk /dev/sda

g  #-> gpt for efi
n  #-> new partition  +550M  for efi partition
n  #-> new partition  +2G  for swap partitiopn
n  #-> new partition  +default  for linux filesystem partitiopn

t  #-> change partition 1 type  -> efi: 1
t  #-> change partition 2 type  -> linux swap: 19

w  #-> write & quit


### make filesystem
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3

### mount filesystem to the live image i.e. the live environment we are now running
mount /dev/sda3 /mnt


### install the base system for arch
pacstrap /mnt base linux linux-firmware


### Configure the system
### generate an fstab  -> filesystem table
genfstab -U /mnt >> /mnt/etc/fstab

### change root to our new installation
arch-chroot /mnt

### set timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

### set hardware clock
hwclock --systohc

### set locale 
echo -e "en_US.UTF-8 UTF-8\n" >> /etc/locale.gen
echo -e "zh_CN.UTF-8 UTF-8\n" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

### set the hostname
echo archvbox > /etc/hostname

### hosts
echo -e "127.0.0.1      localhost\n" >> /etc/hosts
echo -e "::1            localhost\n" >> /etc/hosts
echo -e "127.0.0.1      archvbox.localdomain    archvbox\n" >> /etc/hosts

### user settings
passwd
useradd -m aka
passwd aka

### grant aka sudo previlege
usermod -aG wheel.audio.video.optical.storage aka

pacman -S sudo
EDITER=vim visudo  # uncomment wheel group

### install grub efiboot manager etc.
pacman -S grub efibootmgr dosfstools os-prober mtools

### make efi dir -> boot directory
mkdir /boot/EFI

### mount efi partition
mount /dev/sda1 /boot/EFI

### install grub
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

### generate grub configuration
grub-mkconfig -o /boot/grub/grub.cfg

### install other packages
pacman -S networkmanager vim git

### enable network manager
systemctl enable NetworkManager

exit

### umount /mnt
umount -l /mnt

### lastly,  reboot
showdown now




