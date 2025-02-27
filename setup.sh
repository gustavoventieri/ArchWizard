#!/bin/bash

set -e 

echo "===== INSTALAÇÃO DO ARCH LINUX ====="

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
parted -s $DISK mkpart ESP fat32 1MiB 513MiB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart primary linux-swap 513MiB 4.5GiB
parted -s $DISK mkpart primary ext4 4.5GiB 100%

echo "===== Formatando Partições ====="
mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2
mkfs.ext4 ${DISK}3

echo "===== Montando Partições ====="
mount ${DISK}3 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

echo "===== Instalando Base do Sistema ====="
pacstrap /mnt base linux linux-firmware nano sudo networkmanager grub efibootmgr

echo "===== Gerando fstab ====="
genfstab -U /mnt >> /mnt/etc/fstab

echo "===== Entrando no Sistema Instalado ====="
arch-chroot /mnt /bin/bash <<EOF

echo "===== Configurando Fuso Horário ====="
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

echo "===== Configurando Locale ====="
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf

echo "===== Configurando Nome do Host ====="
echo "$HOSTNAME" > /etc/hostname
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo "===== Configurando Rede ====="
systemctl enable NetworkManager

echo "===== Definindo Senha do Root ====="
echo "Defina uma senha para o root:"
passwd

echo "===== Criando Usuário Final ====="
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Defina uma senha para o usuário $USERNAME:"
passwd $USERNAME

echo "===== Configurando Sudo ====="
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "===== Instalando e Configurando GRUB ====="
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo "===== Finalizando Instalação ====="
umount -R /mnt
reboot