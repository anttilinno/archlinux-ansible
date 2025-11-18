# Inventories

This directory contains inventory files for different environments and stages of the installation process.

## Directory Structure

```
inventories/
├── lab/              # ISO/installation environment
│   ├── hosts.ini
│   └── group_vars/
│       └── all.yml
└── prod/             # Post-install environment
    ├── hosts.ini
    └── group_vars/
        └── all.yml
```

## Environments

### lab/
**Purpose**: Used during initial OS installation from Arch ISO  
**Connection**: SSH as `root` with password authentication  
**Usage**: Run `playbooks/install-arch-t60.yml` against this inventory

**Host configuration**:
```ini
[t60_iso]
t60 ansible_host=192.168.0.150 ansible_user=root ansible_become=true
```

**When to use**:
- Running the initial Arch installation
- System is booted from Arch ISO
- SSH daemon is running on the ISO

### prod/
**Purpose**: Used after OS installation for configuration management  
**Connection**: SSH as admin user with key-based authentication  
**Usage**: Run `site.yml` and other operational playbooks against this inventory

**Host configuration**:
```ini
[t60]
t60 ansible_host=192.0.2.60 ansible_user=antti ansible_become=true
```

**When to use**:
- After successful installation and reboot
- For ongoing system management
- For applying configuration changes

## Inventory Best Practices

### Variable Precedence

Variables can be defined at multiple levels (lowest to highest precedence):
1. Role defaults (`roles/*/defaults/main.yml`)
2. Inventory group_vars (`inventories/*/group_vars/all.yml`)
3. Inventory host_vars (`inventories/*/host_vars/hostname.yml`)
4. Playbook vars
5. Extra vars (`-e` on command line)

### Organization

- Use `group_vars/` for variables common to all hosts in an inventory
- Use `host_vars/` for host-specific variables
- Keep sensitive data in Ansible Vault encrypted files
- Document all variables with comments

### Multiple Environments

This structure supports multiple environments:
- `lab/`: Development/testing
- `prod/`: Production
- Add `staging/`, `qa/`, etc. as needed

### Security

- Never commit actual IP addresses or credentials
- Use Ansible Vault for sensitive variables:
  ```bash
  ansible-vault encrypt inventories/prod/group_vars/vault.yml
  ```
- Use `.gitignore` to exclude sensitive files

## Adding New Hosts

1. Add host to appropriate `hosts.ini`:
   ```ini
   [group_name]
   hostname ansible_host=192.0.2.x ansible_user=username
   ```

2. Add host-specific variables in `host_vars/hostname.yml` if needed

3. Add group variables in `group_vars/group_name.yml` if needed

4. Test connectivity:
   ```bash
   ansible -i inventories/prod/hosts.ini hostname -m ping
   ```

## Inventory Formats

Ansible supports multiple inventory formats:

### INI Format (used here)
```ini
[webservers]
web1 ansible_host=192.0.2.10
web2 ansible_host=192.0.2.11

[databases]
db1 ansible_host=192.0.2.20
```

### YAML Format (alternative)
```yaml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.0.2.10
        web2:
          ansible_host: 192.0.2.11
    databases:
      hosts:
        db1:
          ansible_host: 192.0.2.20
```

## Dynamic Inventories

For larger infrastructures, consider dynamic inventories:
- Cloud provider APIs (AWS, Azure, GCP)
- Configuration management databases
- Custom scripts

See: https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html

