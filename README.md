# Arch Linux Ansible

Automated Arch Linux installation and provisioning for laptops and desktops.

## Features

- **Two-stage deployment**: Bare metal install from ISO, then provisioning
- **Hardware flexibility**: BIOS/UEFI, Intel/AMD/NVIDIA, with Optimus support
- **Modular packages**: Toggle package groups on/off per machine
- **Safety first**: Detects existing installations, requires explicit force flag

## Quick Start

```bash
# From controller - install to target booted from Arch ISO
./run.sh install

# On target after reboot - provision the system
mise run provision
```

## Documentation

- [Quickstart Guide](docs/quickstart.md) - Get up and running
- [Overview](docs/overview.md) - Architecture and concepts
- [Configuration](docs/configuration.md) - All variables and options

## Requirements

- Ansible 2.14+ with `community.general` and `ansible.posix` collections
- Target: Arch Linux ISO with SSH enabled

## License

MIT
