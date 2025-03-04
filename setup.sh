#!/bin/bash

set -e
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



lsblk
read -p "Digite o disco onde deseja instalar (exemplo: /dev/sda ou /dev/nvme0n1): " DISK

echo "O disco selecionado foi: $DISK. Isso apagará TODOS os dados!"
read -p "Tem certeza? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" ]]; then
    echo "Instalação cancelada!"
    exit 1
fi

read -p "Digite uma senha para root: " ROOT_PASSWORD
read -p "Digite o nome do usuário: " USERNAME
read -p "Digite a senha do usuário: " PASSWORD

timedatectl set-ntp true


parted -s $DISK mklabel gpt

parted -s ${DISK} mkpart primary fat32 0% 1GB
parted -s ${DISK} set 1 boot on
parted -s ${DISK} mkpart primary btrfs 1GB 51GB
parted -s ${DISK} mkpart primary btrfs 51GB 100%

mkfs.fat -F32 ${DISK}1        
mkfs.btrfs ${DISK}2            
mkfs.btrfs ${DISK}3           


mount ${DISK}2 /mnt
mkdir -p /mnt/boot/efi /mnt/home

mount ${DISK}1 /mnt/boot/efi
mount ${DISK}1 /mnt/boot

mount ${DISK}3 /mnt/home


pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd 

genfstab -U -p /mnt >> /mnt/etc/fstab


arch-chroot /mnt <<EOF


ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc


echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf  


echo "root:arch" | sudo chpasswd

useradd -m -g users -G wheel, storage, power -s /bin/bash kazz

echo "arch:arch" | sudo chpasswd


echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

pacman -S dosfstools os-prober mtools network-manager-applet wpa_supplicant dialog --noconfirm

pacman -S grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

grub-mkconfig -o /boot/grub/grub.cfg


pacman -S xorg-server xorg-xinit xorg-apps mesa

sudo pacman -S xf86-video-amdgpu
sudo pacman -S xf86-video-intel
sudo pacman -S nvidia nvidia-settings
sudo pacman -S virtualbox-guest-utils

pacman -S gnome-extra gnome-terminal
pacman -S plasma-desktop konsole   
pacman -S gdm

systemctl enable gdm
systemctl enable NetworkManager 

EOF

reboot