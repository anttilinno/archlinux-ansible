# archlinux-ansible

Two-stage Arch Linux deployment system for laptops and desktops.

- **Stage 0 (Installation)**: Bare metal installation from Arch ISO over SSH
- **Stage 1 (Provisioning)**: Post-installation system configuration

## Prerequisites

- Ansible 2.15+
- Python 3.10+

Install required collections:

```bash
ansible-galaxy install -r requirements.yml
```

## Setup

Inventory files are not tracked by git. Copy the `.example` templates and customize for your machine:

```bash
# Installation inventory
cp inventories/install/hosts.ini.example inventories/install/hosts.ini
cp inventories/install/group_vars/all.yml.example inventories/install/group_vars/all.yml
cp inventories/install/group_vars/target.yml.example inventories/install/group_vars/target.yml

# Provisioning inventory
cp inventories/provision/hosts.ini.example inventories/provision/hosts.ini
cp inventories/provision/group_vars/all.yml.example inventories/provision/group_vars/all.yml
cp inventories/provision/host_vars/archbox.yml.example inventories/provision/host_vars/<your-hostname>.yml
```

Edit the copied files to match your hardware and preferences.

## Usage

### Stage 0: Installation (from Arch ISO)

Boot the target machine from the Arch ISO, enable SSH (`passwd` + `systemctl start sshd`), then from the controller:

```bash
./run.sh install
```

This will partition the disk, install base packages, configure the bootloader, and create your admin user. The playbook prompts for the admin password.

### Stage 1: Provisioning

After the installed system has rebooted:

```bash
./run.sh                          # Run full provisioning
./run.sh site --tags docker       # Run specific tags only
./run.sh site --tags virt         # Only virtualization
```

### Local execution (on the target machine)

If running locally instead of over SSH, install [mise](https://mise.jdx.dev/) and use:

```bash
mise run install      # Install Ansible Galaxy collections
mise run provision    # Run provisioning locally
mise run check        # Dry-run provisioning
mise run lint         # Run yamllint and ansible-lint
```

## Package Groups

Toggle groups in `inventories/provision/group_vars/all.yml`:

| Variable | Packages | Default |
|---|---|---|
| `common_cli_enabled` | zoxide, fzf, fd, eza, bat, ripgrep, jq, btop, cyme | `true` |
| `common_shell_enabled` | zsh, starship | `true` |
| `common_git_enabled` | git, lazygit, github-cli | `true` |
| `common_filemanager_enabled` | yazi + dependencies | `true` |
| `common_terminal_enabled` | zellij | `true` |
| `common_fonts_enabled` | JetBrains Mono Nerd, Noto emoji | `true` |
| `common_dev_enabled` | chezmoi, stylua, shfmt, luarocks, nodejs | `false` |
| `common_docker_enabled` | docker, docker-compose, lazydocker | `false` |
| `common_devops_enabled` | aws-cli-v2, kubectl, helm, kubeseal, opentofu-bin | `false` |
| `common_audio_enabled` | pipewire, wireplumber, alsa-utils, pavucontrol | `false` |
| `common_bluetooth_enabled` | bluez, bluez-utils, blueman | `false` |
| `common_i3_enabled` | xorg, i3-wm, polybar, rofi, wezterm | `false` |
| `common_virt_enabled` | qemu-desktop, libvirt, virt-manager, dnsmasq, edk2-ovmf | `false` |
| `common_office_enabled` | audacity, libreoffice, obsidian, slack | `false` |
| `common_aur_enabled` | shellcheck-bin, i3lock-color, zen-browser | `false` |

## Project Structure

```
.
├── run.sh                          # Entry point wrapper script
├── site.yml                        # Stage 1 provisioning playbook
├── playbooks/
│   └── install-arch.yml            # Stage 0 installation playbook
├── inventories/
│   ├── install/                    # Stage 0 inventory (root@ISO)
│   │   ├── hosts.ini.example
│   │   └── group_vars/
│   └── provision/                  # Stage 1 inventory (admin user)
│       ├── hosts.ini.example
│       ├── group_vars/
│       └── host_vars/
├── roles/
│   ├── arch_install/               # Partitioning, pacstrap, bootloader, users
│   └── common/                     # Package groups and services
└── requirements.yml                # Ansible Galaxy dependencies
```

## License

MIT
