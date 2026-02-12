# archlinux-ansible

Two-stage Arch Linux deployment system for laptops and desktops.

- **Stage 0 (Installation)**: Bare metal installation from Arch ISO over SSH
- **Stage 1 (Provisioning)**: Post-installation system configuration

## Quick Start

```bash
# Install Ansible collections
ansible-galaxy install -r requirements.yml

# Copy inventory templates and customize
cp inventories/install/hosts.ini.example inventories/install/hosts.ini
cp inventories/install/group_vars/all.yml.example inventories/install/group_vars/all.yml
cp inventories/install/group_vars/target.yml.example inventories/install/group_vars/target.yml
cp inventories/provision/hosts.ini.example inventories/provision/hosts.ini
cp inventories/provision/group_vars/all.yml.example inventories/provision/group_vars/all.yml
cp inventories/provision/host_vars/archbox.yml.example inventories/provision/host_vars/<your-hostname>.yml

# Stage 0: Install from Arch ISO
./run.sh install

# Stage 1: Provision after reboot
./run.sh
```

## Documentation

- [Quickstart Guide](docs/quickstart.md) - Step-by-step setup
- [Overview](docs/overview.md) - Architecture and package groups
- [Configuration](docs/configuration.md) - All variables and options
- [Machine Management](docs/machine-management.md) - Managing multiple machines

## License

MIT
