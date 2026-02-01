# Inventories

This directory contains inventory files for different stages of the installation process.

## Directory Structure

```
inventories/
├── install/          # ISO/installation environment
│   ├── hosts.ini
│   └── group_vars/
│       └── all.yml
└── provision/        # Post-install environment
    ├── hosts.ini
    └── group_vars/
        └── all.yml
```

## Environments

### install/
**Purpose**: Used during initial OS installation from Arch ISO
**Connection**: SSH as `root` with password authentication
**Usage**: Run `playbooks/install-arch.yml` against this inventory

**Host configuration**:
```ini
[target]
archbox ansible_host=192.168.0.150 ansible_user=root ansible_become=true
```

**When to use**:
- Running the initial Arch installation
- System is booted from Arch ISO
- SSH daemon is running on the ISO

### provision/
**Purpose**: Used after OS installation for configuration management
**Connection**: SSH as admin user with key-based authentication, or local
**Usage**: Run `site.yml` against this inventory

**Host configuration**:
```ini
[laptops]
archbox ansible_host=127.0.0.1 ansible_connection=local
```

**When to use**:
- After successful installation and reboot
- For ongoing system management
- For applying configuration changes

## Variable Precedence

Variables can be defined at multiple levels (lowest to highest precedence):
1. Role defaults (`roles/*/defaults/main.yml`)
2. Inventory group_vars (`inventories/*/group_vars/all.yml`)
3. Inventory host_vars (`inventories/*/host_vars/hostname.yml`)
4. Playbook vars
5. Extra vars (`-e` on command line)

## Adding New Hosts

1. Add host to appropriate `hosts.ini`:
   ```ini
   [laptops]
   hostname ansible_host=192.0.2.x ansible_user=username
   ```

2. Add host-specific variables in `host_vars/hostname.yml` if needed

3. Test connectivity:
   ```bash
   ansible -i inventories/provision/hosts.ini hostname -m ping
   ```
