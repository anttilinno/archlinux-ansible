# Ansible T60 Bootstrap & Provisioning

A comprehensive Ansible project for bare metal Arch Linux installation and post-installation provisioning on a ThinkPad T60.

## Project Structure

```
.
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Galaxy dependencies
├── site.yml                 # Main post-install playbook
├── inventories/
│   ├── lab/                 # ISO environment inventory
│   │   ├── hosts.ini
│   │   └── group_vars/
│   │       └── all.yml
│   └── prod/                # Post-install inventory
│       ├── hosts.ini
│       └── group_vars/
│           └── all.yml
├── playbooks/
│   └── install-arch-t60.yml # Stage-0 installation playbook
└── roles/
    ├── arch_install/        # Bare metal installation role
    │   ├── defaults/
    │   ├── handlers/
    │   ├── meta/
    │   ├── tasks/
    │   └── README.md
    └── common/              # Common baseline configuration
        ├── defaults/
        ├── handlers/
        ├── meta/
        ├── tasks/
        └── README.md
```

## Components

### Playbooks
- **`playbooks/install-arch-t60.yml`**: Stage-0 **destructive** installer run from Arch ISO over SSH
- **`site.yml`**: Post-install provisioning (packages, services, configuration)

### Roles
- **`arch_install`**: Automates complete Arch Linux installation including partitioning, pacstrap, and bootloader
- **`common`**: Baseline configuration and packages for all systems

### Inventories
- **`lab`**: Used when connecting to the Arch ISO (root user, password auth)
- **`prod`**: Used after installation (admin user, key-based auth)

## Prerequisites

### On the Controller (your workstation)
```bash
# Install Ansible
sudo pacman -S ansible

# Install required collections
ansible-galaxy install -r requirements.yml
```

### On the Target (T60)
1. Boot Arch Linux ISO
2. Enable SSH: `systemctl start sshd`
3. Set root password: `passwd`
4. Configure network connectivity

## Quick Start

### Step 1: Install Arch Linux from ISO

**WARNING**: This will wipe the target disk. Ensure you have backups!

```bash
# Run the installer from the ISO environment
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml \
  --ask-pass
```

The installer will:
- Partition the disk (MBR: swap + ext4 root)
- Install base Arch system with specified packages
- Configure locale, timezone, hostname
- Set up admin user with SSH key
- Install and configure Syslinux bootloader
- Reboot into the new system

### Step 2: Post-Install Provisioning

After the system reboots, apply post-installation configuration:

```bash
# Test connectivity
ansible -i inventories/prod/hosts.ini all -m ping

# Run post-install provisioning
ansible-playbook -i inventories/prod/hosts.ini site.yml
```

## Configuration

### Installation Variables

Edit `inventories/lab/group_vars/all.yml` or pass via command line:

```yaml
arch_install_disk: /dev/sda              # Target disk
arch_install_hostname: t60               # System hostname
arch_install_admin_user: antti           # Admin username
arch_install_timezone: Europe/Tallinn    # Timezone
```

See `roles/arch_install/README.md` for all available variables.

### Post-Install Variables

Edit `inventories/prod/group_vars/all.yml`:

```yaml
common_packages:
  - vim
  - htop
  - git
  # ... add more packages
```

## Safety Features

- **Idempotent**: Safe to run multiple times (unless `arch_install_force_repartition=true`)
- **Safety pause**: 10-second warning before destructive operations
- **State marker**: Tracks installation completion to prevent accidents
- **Validation**: Checks for required tools and existing installations

## Tags

Control execution with tags:

```bash
# Run only partitioning
ansible-playbook ... --tags partitioning

# Skip bootloader installation
ansible-playbook ... --skip-tags bootloader

# Available tags: sanity_checks, partitioning, mount, mirrors, 
#                 pacstrap, configure, users, services, bootloader, finalize
```

## Best Practices Implemented

✓ **Role-based structure**: Modular, reusable roles  
✓ **Variable precedence**: Defaults in roles, overrides in inventories  
✓ **Fully Qualified Collection Names (FQCNs)**: All modules use FQCNs  
✓ **Idempotency**: Safe to re-run without side effects  
✓ **Error handling**: Block/rescue patterns for critical sections  
✓ **Tags**: Selective execution support  
✓ **Documentation**: README files for all components  
✓ **Handlers**: Proper separation of concerns  
✓ **Check mode compatibility**: Where possible  

## Customization

### Adding New Roles

```bash
mkdir -p roles/my_role/{defaults,tasks,handlers,meta,templates,files}
```

### Adding to Existing Inventories

Edit the appropriate `hosts.ini` and `group_vars/all.yml` files.

## Troubleshooting

### Installation Issues
- Verify network connectivity on ISO
- Check mirror availability
- Ensure target disk exists and is accessible
- Review `/var/log/pacman.log` for package issues

### Post-Install Issues
- Verify SSH key is correctly installed
- Check NetworkManager is running: `systemctl status NetworkManager`
- Ensure inventory uses correct IP address

## License

MIT

## Author

Antti

## Contributing

This is a personal infrastructure project. Feel free to fork and adapt to your needs.
