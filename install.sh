############################## install to ssd ############################

# 1. internet config 
# wifi-menu iwctl
timedatectl set-ntp true



# 2. disks 
# a partition
lsblk
fdisk /dev/sda    # g --> create a new GPT disklabel    n +512M  n +16G   n default w

# b formate
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon /dev/sda2

# mount
mount /dev/sda3 /mnt

# 3. install 
pacstrap /mnt base linux linux-firmware vim

# 4. generate fs table
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# chane env from iso -> installation 
arch-chroot /mnt

# 5. change time zone 
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# 6. locale settings
# change locales
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# 7. hostname settings
echo alpha > /etc/hostname
echo '
127.0.0.1        localhost
::1              localhost
127.0.0.1        alpha
' > /etc/hosts

# 8. change root pwd
passwd

# 9. install boot loader: grub
pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools wpa_supplicant wireless_tools openssh git base-devel linux-headers os-prober

# 10. format efi partition 
mkfs.fat -F32 /dev/sda1

# 11. boot this partition to efi dir 
mkdir /boot/efi
mount /dev/sda1 /boot/efi

# 12. install grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# 13. gen grub configuration file
grub-mkconfig -o /boot/grub/grub.cfg

# 14. enable services
systemctl enable NetworkManager

# 15. create sudo user
useradd -mG wheel akatsuki
passwd akatsuki
# change wheel group 
EDITOR=vim visudo  # %wheel ALL=(ALL) ALL

# 16. exit & unmount & reboot
exit && umount -a && reboot

# 17. install pkgs
# install graphic driver
pacman -S xf86-video-vesa xf86-video-ati xf86-video-intel xf86-video-amdgpu xf86-video-nouveau
# install desktop env
pacman -S xorg sddm plasma kde-applications konsole chromium 
# enable desktop manager
systemctl enable sddm 

# rebot 
reboot

# 18. customize












################################  install to usb stick ###########################

# boot up arch system

# connect to network  --> iwctl 

# config arch pkgs mirrorlist
echo '##
## Arch Linux repository mirrorlist
## Generated on 2020-11-12

## China
#Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch
#Server = http://mirrors.zju.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
pacman -Syy

# create new partition
lsblk
gdisk /dev/sdc # new partition 1. ef00 2. default

mkfs.fat -F32 /dev/sdc1
mkfs.ext4 -O "^has_journal" /dev/sdc2


# mount
mount /dev/sdc2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sdc1 /mnt/boot/efi

pacstrap /mnt base linux linux-firmware vim


# gen filesystem table
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# chroot
arch-chroot /mnt

# change time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# change locales
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

# gen locales
locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# change hostname archusb
echo 'archusb' > /etc/hostname
echo '
127.0.0.1        localhost
::1              localhost
127.0.0.1        archusb.localdomain archusb
' > /etc/hosts

# change pwd
passwd

# install pkgs
pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools reflector git base-devel linux-headers bluez bluez-utils cups xdg-utils xdg-user-dirs

sed -i 's/^HOOKS=.*$/HOOKS=(base udev block keyboard autodetect modconf filesystems fsck)' /etc/mkinitcpio.conf

mkinitcpio -p linux

# install grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable --recheck

grub-mkconfig -o /boot/grub/grub.cfg


# enable services
systemctl enable networkmanager
systemctl enable bluetooth
systemctl enable org.cups.cupsd

# create sudo user
useradd -mG wheel akatsuki
passwd akatsuki

# change wheel group 
EDITOR=vim visudo  # %wheel ALL=(ALL) ALL

# back to iso
exit

# unmount old partitions
umount -a 

# reboot
reboot


# check network connection
sudo su 

ip a

# config the system journal configuraation file ---> avoid to many writes
mkdir /etc/systemd/journald.conf.d
echo '[Journal]
Storage=volatile
RuntimeMaxUse=30M
' > /etc/systemd/journald.conf.d/usbstick.conf

# install graphic driver
pacman -S xf86-video-vesa xf86-video-ati xf86-video-intel xf86-video-amdgpu xf86-video-nouveau
# install desktop env
pacman -S xorg sddm plasma konsole packagekit-qt5 chromium 
# enable desktop manager
systemctl enable sddm 

# reboot 
reboot 

# attention --> we should shutdown system gracefully because we disable the journal mechnism
