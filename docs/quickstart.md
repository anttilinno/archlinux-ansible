# Quickstart Guide

## Prerequisites

### Controller (your workstation)

```bash
sudo pacman -S ansible
ansible-galaxy install -r requirements.yml
```

### Target machine

1. Boot Arch Linux ISO
2. Enable SSH: `systemctl start sshd`
3. Set root password: `passwd`
4. Note the IP address: `ip addr`

For systems with 4GB RAM, increase tmpfs at boot menu (press TAB, append `tmpfs.size=4G`).

## Step 1: Configure inventory

Edit `inventories/install/hosts.ini`:

```ini
[target]
myhost ansible_host=192.168.1.100 ansible_user=root ansible_become=true
```

Edit `inventories/install/group_vars/all.yml`:

```yaml
arch_install_hostname: myhost
arch_install_disk: /dev/sda
arch_install_admin_user: myuser
arch_install_cpu: intel      # intel, amd, or none
arch_install_gpu: intel      # intel, amd, nvidia, or none
arch_install_boot_mode: bios # bios or uefi
```

## Step 2: Install Arch Linux

**WARNING**: This will wipe the target disk!

```bash
./run.sh install
```

You'll be prompted for:
- Root password (for SSH to ISO)
- New admin user password

The system will reboot automatically after installation.

## Step 3: Provision the system

After reboot, on the target machine:

```bash
cd ~/archlinux-ansible
mise run provision
```

Or from controller:

```bash
./run.sh
```

## Step 4: Customize packages

Edit `inventories/provision/group_vars/all.yml` to enable/disable package groups:

```yaml
common_cli_enabled: true      # zoxide, fzf, ripgrep, etc.
common_docker_enabled: false  # docker, docker-compose
common_i3_enabled: false      # i3-wm, polybar, rofi
```

Re-run provisioning to apply changes:

```bash
mise run provision
```

## Next steps

- [Overview](overview.md) - Understand the architecture
- [Configuration](configuration.md) - All available options
