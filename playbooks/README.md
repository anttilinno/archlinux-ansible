# Playbooks

This directory contains playbooks for various stages of system lifecycle.

## Available Playbooks

### install-arch.yml
**Purpose**: Bare metal Arch Linux installation from ISO environment
**Target**: `target` (Arch ISO via SSH as root)
**Inventory**: `inventories/install/hosts.ini`
**Destructive**: YES - partitions and formats disk

**Usage**:
```bash
./run.sh install
# or
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventories/install/hosts.ini \
  playbooks/install-arch.yml \
  --ask-pass
```

**What it does**:
- Partitions disk (MBR: swap + root, or GPT for UEFI)
- Formats filesystems (swap + ext4)
- Installs base Arch Linux system
- Configures locale, timezone, hostname
- Sets up users and SSH keys
- Installs bootloader (syslinux for BIOS, limine for UEFI)
- Reboots into new system

**Safety features**:
- Checks for existing installation
- 10-second pause before destructive operations
- Idempotent when `arch_install_force_repartition=false`

**Variables**:
See `roles/arch_install/defaults/main.yml` for all options.

**Tags**:
- `sanity_checks`: Pre-flight checks
- `partitioning`: Disk operations
- `mount`: Filesystem mounting
- `mirrors`: Mirror configuration
- `pacstrap`: Base system installation
- `configure`: System configuration
- `users`: User setup
- `services`: Service enablement
- `bootloader`: Bootloader installation
- `finalize`: Cleanup and reboot

## Examples

Run only partitioning:
```bash
ansible-playbook -i inventories/install/hosts.ini \
  playbooks/install-arch.yml \
  --tags partitioning
```

Skip bootloader installation:
```bash
ansible-playbook -i inventories/install/hosts.ini \
  playbooks/install-arch.yml \
  --skip-tags bootloader
```

Use different disk:
```bash
ansible-playbook -i inventories/install/hosts.ini \
  playbooks/install-arch.yml \
  -e "arch_install_disk=/dev/nvme0n1"
```
