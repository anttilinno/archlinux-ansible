# Machine Management

Prevent package drift across multiple machines by running provisioning periodically.

## Adding Machines

### 1. Add host to inventory

Inventory files are gitignored. If starting fresh, copy from templates first:

```bash
cp inventories/provision/hosts.ini.example inventories/provision/hosts.ini
cp inventories/provision/group_vars/all.yml.example inventories/provision/group_vars/all.yml
```

Edit `inventories/provision/hosts.ini`:

```ini
[laptops]
thinkpad ansible_host=192.168.1.10
xps ansible_host=192.168.1.11

[desktops]
workstation ansible_host=192.168.1.20
```

For local execution, use:
```ini
[laptops]
thinkpad ansible_host=127.0.0.1 ansible_connection=local
```

### 2. Create host-specific variables (optional)

Create `inventories/provision/host_vars/<hostname>.yml` for machine-specific overrides:

```yaml
# inventories/provision/host_vars/workstation.yml
machine_type: desktop
common_office_enabled: true
common_i3_enabled: false
```

Variables in host_vars override group_vars.

## Running Provisioning

### All machines

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml
```

### Specific machine

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml --limit thinkpad
```

### Specific group

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml --limit laptops
```

### Dry-run first

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml --check
```

### Show what would change

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml --check --diff
```

## Common Workflows

### Sync all machines after changing group_vars

```bash
# Edit common settings
vim inventories/provision/group_vars/all.yml

# Apply to all
ansible-playbook -i inventories/provision/hosts.ini site.yml
```

### Add package group to one machine

```bash
# Create or edit host_vars
echo "common_docker_enabled: true" >> inventories/provision/host_vars/thinkpad.yml

# Apply to that machine
ansible-playbook -i inventories/provision/hosts.ini site.yml --limit thinkpad
```

### Check drift without fixing

```bash
ansible-playbook -i inventories/provision/hosts.ini site.yml --check --diff
```

Review output - "changed" tasks indicate drift.

### Run specific package group only

```bash
# Only docker-related tasks
ansible-playbook -i inventories/provision/hosts.ini site.yml --tags docker
```

## Variable Hierarchy

From lowest to highest priority:

1. `roles/common/defaults/main.yml` - Role defaults
2. `inventories/provision/group_vars/all.yml` - All machines
3. `inventories/provision/group_vars/laptops.yml` - Group-specific
4. `inventories/provision/host_vars/<hostname>.yml` - Machine-specific
5. Command line `-e "var=value"` - Runtime override

## Example Setup

```
inventories/provision/
├── hosts.ini
├── group_vars/
│   ├── all.yml          # Common: cli, shell, git, fonts
│   ├── laptops.yml      # Laptops: audio, power management
│   └── desktops.yml     # Desktops: nvidia, office apps
└── host_vars/
    ├── thinkpad.yml     # ThinkPad-specific
    ├── xps.yml          # XPS-specific
    └── workstation.yml  # Workstation-specific
```
