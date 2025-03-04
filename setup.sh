#!/bin/bash

set -e 

#!/bin/bash

echo -e "
  ___           _       _    _ _                  _                     
 / _ \         | |     | |  | (_)                | |   
/ /_\ \_ __ ___| |__   | |  | |_ ______ _ _ __ __| |
|  _  | '__/ __| '_ \  | |/\| | |_  / _\` | '__/ _\` |
| | | | | | (__| | | | \  /\  / |/ / (_| | | | (_| |
\_| |_/_|  \___|_| |_|  \/  \/|_/___\__,_|_|  \__,_|

                  .

                   .
         /^\     .
    /\   \"V\"
   /__\   I      O  o
  //..\\   I     .
  \].\`[/  I
  /l\/j\  (]    .  O
 /. ~~ ,\/I          .
 \\L__j^\/ I       o
  \/--v}  I     o   .
  |    |  I   _________
  |    |  I c(\`       ')o
  |    l  I   \.     ,/
_/j  L l\_!  _//^---^\\_
"


loadkeys br-abnt2

parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary fat32 0% 1GB
parted -s /dev/sda set 1 boot on
parted -s /dev/sda mkpart primary btrfs 1GB 51GB
parted -s /dev/sda mkpart primary btrfs 51GB 100%

mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/sda2
mkfs.btrfs /dev/sda3

mount /dev/sda2 /mnt
mkdir -p /mnt/home /mnt/boot/efi

mount /dev/sda3 /mnt/home
mount /dev/sda1 /mnt/boot/efi

pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<EOF

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

hwclock --systohc

echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

echo "root:Senha123$" | sudo chpasswd

useradd -m -g users -G wheel, storage, power -s /bin/bash kazz

echo "usuario:Senha123$" | sudo chpasswd

pacman -S dosfstools os-prober mtools network-manager-applet wpa_supplicant dialog grub efibootmgr --noconfirm

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

grub-mkconfig -o /boot/grub/grub.cfg

pacman -S xorg-server xorg-xinit xorg-apps mesa --noconfirm

sudo pacman -S xf86-video-amdgpu --noconfirm
sudo pacman -S xf86-video-intel --noconfirm
sudo pacman -S nvidia nvidia-settings --noconfirm
sudo pacman -S virtualbox-guest-utils --noconfirm

pacman -S gnome-extra gnome-terminal --noconfirm
pacman -S plasma-desktop konsole --noconfirm
pacman -S gdm --noconfirm

systemctl enable gdm
systemctl enable NetworkManager

EOF