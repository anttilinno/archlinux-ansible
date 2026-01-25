# T60 Minimal Install Guide

Manual Arch Linux installation for ThinkPad T60 with limited RAM, followed by Ansible provisioning.

## Hardware Reference

- **CPU**: Intel T7200
- **RAM**: 2x2GB (4GB total)
- **GPU**: Intel GMA 950 (945GM)
- **Display**: 1024x768 (XGA) 14.1" 4:3
- **Disk**: Corsair Force LS 120GB SSD

## Prerequisites

- Arch Linux ISO on USB
- Network connectivity (Ethernet recommended)
- SSH public key from controller machine

## Step 1: Boot and Network

```bash
# Boot from Arch ISO

# Set readable console font (T60 has 1024x768 display)
setfont ter-v22b

# Verify boot mode (should fail on T60 - it's BIOS/MBR)
ls /sys/firmware/efi

# Connect to network
# Ethernet: should auto-connect
# WiFi:
iwctl
station wlan0 connect YOUR_SSID

# Verify connectivity
ping -c 3 archlinux.org
```

## Step 2: Partition Disk

```bash
# Identify disk
lsblk

# Partition (MBR layout)
fdisk /dev/sda

# Create partitions:
# 1. Swap: +4G, type 82 (Linux swap)
# 2. Root: remaining space, type 83 (Linux)

# Or use this layout:
# /dev/sda1 - 4GB swap
# /dev/sda2 - rest as ext4 root
```

Example fdisk commands:
```
o        # Create new MBR partition table
n        # New partition (swap)
p        # Primary
1        # Partition 1
<enter>  # Default first sector
+4G      # 4GB size
t        # Change type
82       # Linux swap

n        # New partition (root)
p        # Primary
2        # Partition 2
<enter>  # Default first sector
<enter>  # Use remaining space

a        # Toggle bootable flag
2        # On partition 2

w        # Write and exit
```

## Step 3: Format and Mount

```bash
# Format
mkswap /dev/sda1
mkfs.ext4 -L archroot /dev/sda2

# Mount
mount /dev/sda2 /mnt
swapon /dev/sda1
```

## Step 4: Install Base System

Minimal package set for Ansible compatibility:

```bash
# Update mirrors (optional but faster)
reflector --country Estonia,Finland,Sweden --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# Install minimal system
pacstrap -K /mnt \
    base \
    linux \
    linux-firmware \
    intel-ucode \
    networkmanager \
    wpa_supplicant \
    openssh \
    sudo \
    python \
    syslinux \
    terminus-font
```

## Step 5: Configure System

```bash
# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt
```

### Timezone and Locale

```bash
# Timezone
ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Keyboard and console font
# T60 has 1024x768 display
cat > /etc/vconsole.conf << EOF
KEYMAP=us
FONT=ter-v22b
EOF

# Test font immediately (optional)
setfont ter-v22b
```

Available terminus sizes: `ter-v{12,14,16,18,20,22,24,28,32}{n,b}` (n=normal, b=bold)
- ter-v18b: more lines on screen
- ter-v22b: balanced (recommended)
- ter-v24b: larger text

### Hostname

```bash
echo "t60" > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   t60.localdomain t60
EOF
```

## Step 6: Create Admin User

```bash
# Create user
useradd -m -G wheel -s /bin/bash antti

# Set password
passwd antti

# Enable sudo for wheel group (no password for Ansible)
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
```

## Step 7: SSH Access

```bash
# Create SSH directory
mkdir -p /home/antti/.ssh

# Add your public key (copy from controller)
cat > /home/antti/.ssh/authorized_keys << 'EOF'
ssh-ed25519 AAAA... your-key-here
EOF

# Set permissions
chown -R antti:antti /home/antti/.ssh
chmod 700 /home/antti/.ssh
chmod 600 /home/antti/.ssh/authorized_keys
```

## Step 8: Enable Services

```bash
systemctl enable sshd
systemctl enable NetworkManager
```

## Step 9: Bootloader (Syslinux)

```bash
# Install to MBR
syslinux-install_update -iam

# Verify config exists
cat /boot/syslinux/syslinux.cfg
```

If syslinux.cfg needs fixing:

```bash
# Get root partition UUID
blkid /dev/sda2

# Edit config
cat > /boot/syslinux/syslinux.cfg << 'EOF'
DEFAULT arch
PROMPT 0
TIMEOUT 50

LABEL arch
    LINUX ../vmlinuz-linux
    APPEND root=LABEL=archroot rw
    INITRD ../intel-ucode.img,../initramfs-linux.img
EOF
```

## Step 10: Exit and Reboot

```bash
# Exit chroot
exit

# Unmount
umount -R /mnt
swapoff /dev/sda1

# Reboot
reboot
```

Remove USB drive when prompted.

## Step 11: Verify Boot

After reboot:

```bash
# Login as antti

# Check network
ip addr
ping -c 3 archlinux.org

# Check SSH is running
systemctl status sshd
```

## WiFi Configuration

### During Install (from live ISO)

```bash
# Interactive WiFi setup
iwctl

# Inside iwctl:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect YOUR_SSID
# Enter password when prompted
exit
```

### After Reboot (using NetworkManager)

```bash
# List available networks
nmcli device wifi list

# Connect to network
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"

# Verify connection
nmcli connection show

# Check IP
ip addr show wlan0
```

### Make WiFi Connection Persistent

NetworkManager saves connections automatically. To verify:

```bash
# List saved connections
nmcli connection show

# Auto-connect on boot (should be default)
nmcli connection modify "YOUR_SSID" connection.autoconnect yes
```

### Identify WiFi Chipset

```bash
# Find wireless device
lspci | grep -i wireless
# or
lspci | grep -i network

# Common T60 chipsets:
# - Intel PRO/Wireless 3945ABG (iwl3945 driver, included in linux-firmware)
# - Atheros (ath5k driver, included in linux-firmware)
```

### Troubleshooting WiFi

```bash
# Check if interface exists
ip link show

# Check if driver loaded
lspci -k | grep -A3 -i wireless

# Bring interface up manually
sudo ip link set wlan0 up

# Check NetworkManager sees the device
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check logs
journalctl -u NetworkManager -f
```

## Step 12: Ansible Provisioning

From your controller machine:

```bash
cd ~/Repos/Misc/ansible-t60

# Update inventory with T60's IP if needed
# vim inventories/prod/hosts.ini

# Test connectivity
ansible -i inventories/prod/hosts.ini all -m ping

# Run post-install provisioning
ansible-playbook -i inventories/prod/hosts.ini site.yml
```

## Post-Install Notes

### Wake-on-LAN Issue

The T60 may not shut down properly. Disable WoL:

```bash
# Check current setting
ethtool eth0 | grep Wake-on

# Disable (add to NetworkManager dispatcher or systemd service)
ethtool -s eth0 wol d
```

### Graphics Drivers

If not installed by Ansible, add manually:

```bash
sudo pacman -S mesa xf86-video-intel
```

## Troubleshooting

### No network after reboot

```bash
# Check NetworkManager
systemctl status NetworkManager

# Start manually
sudo systemctl start NetworkManager

# Connect WiFi
nmcli device wifi connect YOUR_SSID password YOUR_PASSWORD
```

### SSH connection refused

```bash
# Check sshd
sudo systemctl status sshd
sudo systemctl start sshd

# Check firewall (if installed)
sudo iptables -L
```

### Boot fails

Boot from USB again and:

```bash
mount /dev/sda2 /mnt
arch-chroot /mnt

# Reinstall/reconfigure syslinux
syslinux-install_update -iam

# Regenerate initramfs
mkinitcpio -P
```
