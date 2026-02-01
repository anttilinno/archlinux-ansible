# Arch Install Role

## Description

A comprehensive Ansible role for bare metal Arch Linux installation on legacy BIOS systems. This role automates the entire installation process including partitioning, filesystem creation, base system installation, and bootloader configuration.

## Requirements

- Arch Linux ISO booted on target machine
- SSH access to the ISO environment (typically as root)
- Network connectivity
- Target system must support legacy BIOS boot

## Role Variables

### Hardware Configuration
- `arch_install_disk`: Target disk device (default: `/dev/sda`)
- `arch_install_root_fs_label`: Filesystem label for root partition (default: `archroot`)

### System Configuration
- `arch_install_hostname`: System hostname (default: `archbox`)
- `arch_install_locale`: System locale (default: `en_US.UTF-8`)
- `arch_install_timezone`: System timezone (default: `Europe/Tallinn`)
- `arch_install_keymap`: Console keymap (default: `us`)

### User Configuration
- `arch_install_admin_user`: Admin username (default: `antti`)
- `arch_install_admin_shell`: Admin user shell (default: `/bin/zsh`)
- `arch_install_admin_pubkey`: SSH public key for admin user
- `arch_install_admin_password_hash`: Hashed password for admin user (use vars_prompt)
- `arch_install_root_password_hash`: Root password hash (default: `!*` - locked)

### Safety Toggles
- `arch_install_force_repartition`: Force repartitioning (default: `false`) **DESTRUCTIVE**
- `arch_install_state_marker`: Installation completion marker path

### Partition Layout
- `arch_install_swap_start`: Swap partition start (default: `1MiB`)
- `arch_install_swap_end`: Swap partition end (default: `4GiB`)

### Package Configuration
- `arch_install_base_packages`: List of packages to install with pacstrap

### Mirror Configuration
- `arch_install_mirror_refresh_interval_secs`: Mirror refresh interval (default: `86400`)
- `arch_install_reflector_timeout_secs`: Reflector timeout (default: `20`)
- `arch_install_skip_mirror_refresh`: Skip mirror refresh (default: `false`)
- `arch_install_reflector_countries`: List of countries for reflector

### Reboot Behavior
- `arch_install_perform_reboot`: Automatically reboot after installation (default: `true`)
- `arch_install_reboot_timeout`: Reboot timeout in seconds (default: `180`)

## Dependencies

This role requires the following Ansible collections:
- `community.general`
- `ansible.posix`

Install them with:
```bash
ansible-galaxy collection install community.general ansible.posix
```

## Example Playbook

```yaml
---
- name: Install Arch Linux from ISO
  hosts: target
  become: true
  gather_facts: false

  vars_prompt:
    - name: arch_install_admin_password_hash
      prompt: "New admin password for user"
      private: true
      confirm: true
      encrypt: sha512_crypt
      salt_size: 8

  roles:
    - role: arch_install
      arch_install_disk: /dev/sda
      arch_install_hostname: myhost
      arch_install_admin_user: myuser
```

## Tags

- `arch_install`: All tasks in this role
- `sanity_checks`: Sanity checks
- `partitioning`: Disk partitioning and formatting
- `mount`: Filesystem mounting
- `mirrors`: Mirror configuration
- `pacstrap`: Base system installation
- `configure`: System configuration
- `users`: User and authentication setup
- `services`: Service enablement
- `bootloader`: Bootloader installation
- `finalize`: Final steps and reboot

## License

MIT

## Author

Antti

