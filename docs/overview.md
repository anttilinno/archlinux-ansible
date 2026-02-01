# Overview

## Two-Stage Deployment

### Stage 0: Installation

Runs from a controller machine against target booted from Arch ISO.

```
Controller ──SSH──> Target (Arch ISO)
                    │
                    ├── Partition disk
                    ├── Install base system (pacstrap)
                    ├── Configure system
                    ├── Create admin user
                    ├── Install bootloader
                    └── Reboot
```

**Playbook**: `playbooks/install-arch.yml`
**Role**: `arch_install`
**Inventory**: `inventories/install/`

### Stage 1: Provisioning

Runs locally on the installed system (or remotely from controller).

```
Target ──local──> Ansible
                  │
                  ├── Install package groups
                  ├── Configure services
                  └── Apply system settings
```

**Playbook**: `site.yml`
**Role**: `common`
**Inventory**: `inventories/provision/`

## Directory Structure

```
.
├── inventories/
│   ├── install/          # Stage 0: ISO environment
│   │   ├── hosts.ini
│   │   └── group_vars/
│   └── provision/        # Stage 1: Installed system
│       ├── hosts.ini
│       └── group_vars/
├── playbooks/
│   └── install-arch.yml  # Stage 0 playbook
├── site.yml              # Stage 1 playbook
└── roles/
    ├── arch_install/     # Bare metal installation
    └── common/           # Package and service configuration
```

## Roles

### arch_install

Handles complete Arch Linux installation:

- Disk partitioning (MBR for BIOS, GPT for UEFI)
- Filesystem creation (swap + ext4)
- Base system installation via pacstrap
- System configuration (locale, timezone, hostname)
- User creation with SSH key
- Bootloader installation (syslinux for BIOS, limine for UEFI)

### common

Manages post-install configuration:

- Package groups (CLI tools, shell, fonts, docker, i3, etc.)
- Service enablement (docker socket, pipewire, journald)
- AUR package installation via yay

## Package Groups

Each group can be toggled independently:

| Group | Packages |
|-------|----------|
| `common_cli_enabled` | zoxide, fzf, fd, eza, bat, ripgrep, jq, btop |
| `common_shell_enabled` | zsh, starship |
| `common_git_enabled` | git, lazygit, github-cli |
| `common_filemanager_enabled` | yazi + dependencies |
| `common_terminal_enabled` | zellij |
| `common_fonts_enabled` | JetBrains Mono Nerd, Noto emoji |
| `common_dev_enabled` | chezmoi, stylua, shfmt, luarocks |
| `common_docker_enabled` | docker, docker-compose, lazydocker |
| `common_audio_enabled` | pipewire, wireplumber, alsa-utils |
| `common_i3_enabled` | xorg, i3-wm, polybar, rofi, wezterm |
| `common_aur_enabled` | shellcheck-bin, i3lock-color, zen-browser |
| `common_office_enabled` | audacity, libreoffice, obsidian, slack |

## Variable Precedence

From lowest to highest:

1. Role defaults (`roles/*/defaults/main.yml`)
2. Inventory group_vars (`inventories/*/group_vars/all.yml`)
3. Inventory host_vars (`inventories/*/host_vars/*.yml`)
4. Extra vars (`-e` on command line)

## Safety Features

- **Installation detection**: Checks for existing system at `/mnt/etc/arch-release`
- **Force flag**: Repartitioning requires `arch_install_force_repartition: true`
- **Safety pause**: 10-second countdown before destructive operations
- **State marker**: Tracks completion via `/mnt/root/.ansible-stage0-done`
