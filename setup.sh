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



lsblk
read -p "Digite o disco onde deseja instalar (exemplo: /dev/sda ou /dev/nvme0n1): " DISK

echo "O disco selecionado foi: $DISK. Isso apagará TODOS os dados!"
read -p "Tem certeza? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" ]]; then
    echo "Instalação cancelada!"
    exit 1
fi


read -p "Digite o nome do usuário: " USERNAME
read -p "Digite o nome da máquina (hostname): " HOSTNAME


echo "===== Atualizando relógio ====="
timedatectl set-ntp true


echo "===== Particionando Disco ====="
parted -s $DISK mklabel gpt

# Partição EFI
parted -s $DISK mkpart ESP fat32 1MiB 513MiB
parted -s $DISK set 1 esp on

# Partição Root
parted -s $DISK mkpart primary btrfs 513MiB 50GiB  

# Partição Home
parted -s $DISK mkpart primary btrfs 50GiB 100%  

mkfs.fat -F32 {$DISK}1        
mkfs.btrfs {$DISK}2            
mkfs.btrfs {$DISK}3           



echo "===== Montando Partições ====="
mount ${DISK}3 /mnt
mkdir -p /mnt/home
mkdir -p /mnt/boot
mkdir -p /mnt/boot/efi

mount ${DISK}3 /mnt/home
mount ${DISK}1 /mnt/boot
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi



echo "===== Instalando Base do Sistema ====="
pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd 



echo "===== Gerando fstab ====="
genfstab -U -p /mnt >> /mnt/etc/fstab



echo "===== Entrando no Sistema Instalado ====="
arch-chroot /mnt



echo "===== Configurando Fuso Horário ====="
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc



echo "===== Configurando Locale ====="
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf  



echo "===== Configurando Teclado ====="
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf



echo "===== Definindo Senha do Root ====="
echo "Defina uma senha para o root:"
passwd


echo "===== Criando Usuário Final ====="
useradd -m -g users -G wheel,storage,power -s /bin/bash $USERNAME

echo "Defina uma senha para o usuário $USERNAME:"
passwd $USERNAME



echo "===== Instalando Ferramentas para Dual Boot e Internet ====="
pacman -S dosfstools os-prober mtools network-manager-applet wpa_supplicant dialog

echo "===== Instalando Ferramentas para Configurar o Grub ====="
pacman -S grub efibootmgr



echo "===== Instalando GRUB ====="
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arcg_grub --recheck

echo "===== Configurando Grub ====="
grub-mkconfig -o /boot/grub/grub.cfg

echo "===== Configurando Sudo ====="
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "===== Instalando Interface Grafica ====="
pacman -S xorg-server xorg-xinit xorg-apps mesa

echo "===== Subir Drive de Video ====="
sudo pacman -S xf86-video-amdgpu
sudo pacman -S xf86-video-intel
sudo pacman -S nvidia nvidia-settings
sudo pacman -S virtualbox-guest-utils

echo "===== Instalando Tipo De Interface Grafica ====="
pacman -S gnome-extra gnome-terminal
pacman -S plasma-desktop konsole    

echo "===== Configurando Interface Grafica e Rede ====="
systemctl enable gdm
systemctl enable NetworkManager


echo "===== Finalizando Instalação ====="
exit 
reboot