
##################  step 1
# connect to internet
function connect2network() {
	echo "please connect to netowrk"
	nmtui
}

function configArchRepoMirror() {
	echo "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
	pacman -Syy
}


# sync time
function syncTimedate() {
	timedatectl set-ntp true
}



# create disk partition
function createDiskPartition() {
	lsblk
	fdisk /dev/sda    # g --> create a new GPT disklabel    n +512M  n +16G   n default w
}

# format disk
function formatAndMountDisk() {
	mkfs.ext4 /dev/sda3
	mkswap /dev/sda2
	swapon /dev/sda2
	mount /dev/sda3 /mnt
	# boot partition
	# mkfs.fat -F32 /dev/sda1
	# mkdir /boot/efi
	# mount /dev/sda1 /boot/efi
}

# install base
function createLinuxBase() {
	pacstrap /mnt base linux linux-firmware vim openssh
}

# gen fs table
function genfsTable() {
	genfstab -U /mnt >> /mnt/etc/fstab
	cat /mnt/etc/fstab
}



# change env from iso to -> installation
function changeToInstalledArch() {
	arch-chroot /mnt
}


################# step 2

# config time zone
function setTimezone() {
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	hwclock --systohc
}

# locale settings
function setLocale() {
	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 > /etc/locale.conf
}

# hostname settings
function setHost() {
	echo alpha > /etc/hostname
	echo '127.0.0.1        localhost
::1              localhost
127.0.0.1        alpha' > /etc/hosts
}

# change root password
function changeRootPwd() {
	passwd
}

# install bootLoader
function installBootLoader() {
	pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools openssh git base-devel linux-headers os-prober
}

# install grub
function installGrub() {
	mkfs.fat -F32 /dev/sda1
	mkdir /boot/efi
	mount /dev/sda1 /boot/efi
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
}


#  gen grub configuration file
function genGrubCfg() {
	grub-mkconfig -o /boot/grub/grub.cfg
}

# basic setup
function basicSetup() {
	systemctl enable NetworkManager

	useradd -mG wheel akatsuki
	passwd akatsuki
	EDITOR=vim visudo  # %wheel ALL=(ALL) ALL
}

# last step
# exit && umount -a && reboot


######################### step 3

# connect to network

# install xmonad
function installXmonad() {
	pacman -S xorg xorg-server xorg-xinit xmonad xmonad-contrib xterm
	cp /etc/X11/xinit/xinitrc .xinitrc
	vim .xinitrc
	# exec xmonad
}



function main() {
	if [ $1 == "conn" ]
	then
		connect2network

	elif [ $1 == "setupDisk" ]
	then
		createDiskPartition
		formatAndMountDisk

	elif [ $1 == "step1" ]
	then
		configArchRepoMirror
		syncTimedate
		createLinuxBase
		genfsTable
		changeToInstalledArch

	elif [ $1 == "step2" ]
	then
		setTimezone
		setLocale
		setHost
		changeRootPwd
		installBootLoader
		installGrub
		genGrubCfg
		basicSetup
		# exit && umount -a && reboot

	elif [ $1 == "step3" ]
	then
		installXmonad

	fi
}


main $1








