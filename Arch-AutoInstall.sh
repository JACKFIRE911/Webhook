#!/bin/bash

# === 1. Internet Check ===
ping -c 1 archlinux.org > /dev/null || dhcpcd

# === 2. Time Sync ===
timedatectl set-ntp true

# === 3. Format Partitions ===
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
# Optional home
# mkfs.ext4 /dev/nvme0n1p3

# === 4. Mount ===
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
# mkdir /mnt/home && mount /dev/nvme0n1p3 /mnt/home

# === 5. Install Base System ===
pacstrap -K /mnt base linux linux-firmware nano vim networkmanager grub efibootmgr

# === 6. Generate fstab ===
genfstab -U /mnt >> /mnt/etc/fstab

# === 7. Chroot and Install ===
arch-chroot /mnt /bin/bash <<EOF

# Timezone & Clock
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "archbox" > /etc/hostname

# Root Password
echo root:neeraj@123 | chpasswd

# Add User
useradd -mG wheel neeraj
echo neeraj:neeraj@123 | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable Networking
systemctl enable NetworkManager

# GRUB Install
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# KDE Plasma
pacman -S --noconfirm xorg plasma kde-applications sddm
systemctl enable sddm

EOF

# === 8. Done ===
echo "Setup done. You can reboot now."
