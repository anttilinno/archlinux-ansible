# Playbooks

This directory contains playbooks for various stages of system lifecycle.

## Available Playbooks

### install-arch-t60.yml
**Purpose**: Bare metal Arch Linux installation from ISO environment  
**Target**: `t60_iso` (Arch ISO via SSH as root)  
**Inventory**: `inventories/lab/hosts.ini`  
**Destructive**: YES - partitions and formats disk

**Usage**:
```bash
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml \
  --ask-pass
```

**What it does**:
- Partitions disk (MBR: swap + root)
- Formats filesystems (swap + ext4)
- Installs base Arch Linux system
- Configures locale, timezone, hostname
- Sets up users and SSH keys
- Installs Syslinux bootloader
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

## Best Practices

1. Always test in a safe environment first
2. Review variables before running
3. Use `--check` mode when possible
4. Use `--tags` to run specific sections
5. Keep playbooks focused and modular
6. Use roles for reusable components

## Adding New Playbooks

When adding new playbooks:
1. Follow the naming convention: `verb-target.yml`
2. Add comprehensive comments at the top
3. Use pre_tasks and post_tasks appropriately
4. Document all required variables
5. Add entry to this README
6. Test thoroughly before committing

## Examples

Run only partitioning:
```bash
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml \
  --tags partitioning
```

Skip bootloader installation:
```bash
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml \
  --skip-tags bootloader
```

Use different disk:
```bash
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml \
  -e "arch_install_disk=/dev/nvme0n1"
```

