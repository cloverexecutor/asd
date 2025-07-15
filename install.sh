# ========== START OF SCRIPT ==========

DISK="/dev/vda"
USERNAME="maxey"
PASSWORD="arch"
HOSTNAME="archvm"

# Wipe & Partition
sgdisk -Z "$DISK"
sgdisk -n1:0:+512M -t1:ef00 -c1:EFI "$DISK"
sgdisk -n2:0:0     -t2:8300 -c2:ROOT "$DISK"
mkfs.fat -F32 ${DISK}1
mkfs.ext4 -F ${DISK}2

# Mount
mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

# Base Install
pacstrap /mnt base linux linux-firmware vim networkmanager sudo

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot setup
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$HOSTNAME" > /etc/hostname
echo "KEYMAP=us" > /etc/vconsole.conf

useradd -m -G wheel $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel

bootctl install

PARTUUID=\$(blkid -s PARTUUID -o value ${DISK}2)
cat > /boot/loader/entries/arch.conf <<BOOT
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=PARTUUID=\$PARTUUID rw
BOOT

echo "default arch" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf

systemctl enable NetworkManager
EOF

umount -R /mnt
echo "✅ Arch installed. You can now reboot."

# ========== END OF SCRIPT ==========
