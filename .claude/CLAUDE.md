# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Two-stage Arch Linux deployment system for laptops and desktops:
- **Stage 0 (Installation)**: Bare metal installation from Arch ISO using `arch_install` role
- **Stage 1 (Provisioning)**: Post-installation system configuration using `common` role

## Common Commands

### From controller (remote execution)
```bash
ansible-galaxy install -r requirements.yml  # Install collections

# Installation (DESTRUCTIVE - from Arch ISO)
./run.sh install                # Run installation playbook

# Provisioning
./run.sh                        # Run site.yml (default)
./run.sh site --tags docker     # Run specific tags only
```

### On target machine (local execution via mise)
```bash
mise run install                # Install Ansible Galaxy collections
mise run provision              # Run provisioning locally
mise run check                  # Dry-run provisioning
mise run lint                   # Run yamllint and ansible-lint
mise run test                   # Run all quality checks
```

## Architecture

### Inventories
- **install/**: Used during Stage 0 (root user on Arch ISO, password auth)
- **provision/**: Used during Stage 1 (admin user, local connection by default)

### Roles
- **arch_install**: Complete Arch installation (partitioning, pacstrap, bootloader). Supports BIOS/UEFI, Intel/AMD CPUs, Intel/AMD/NVIDIA GPUs.
- **common**: Package groups and services. Each group is toggleable via `common_*_enabled` variables in `inventories/provision/group_vars/all.yml`.

### Package Groups (common role)
Toggle groups by editing `inventories/provision/group_vars/all.yml`:
- `common_cli_enabled`: zoxide, fzf, fd, eza, bat, ripgrep, jq, btop, cyme (usbutils alternative)
- `common_shell_enabled`: zsh, starship
- `common_git_enabled`: git, lazygit, github-cli
- `common_filemanager_enabled`: yazi + dependencies
- `common_terminal_enabled`: zellij
- `common_fonts_enabled`: JetBrains Mono Nerd, Noto emoji
- `common_dev_enabled`: chezmoi, stylua, shfmt
- `common_docker_enabled`: docker, docker-compose, lazydocker
- `common_devops_enabled`: aws-cli-v2, opentofu-bin
- `common_audio_enabled`: pipewire, wireplumber, alsa-utils
- `common_i3_enabled`: xorg, i3-wm, polybar, rofi, wezterm
- `common_aur_enabled`: shellcheck-bin, i3lock-color, zen-browser
- `common_office_enabled`: audacity, libreoffice, obsidian, slack

### Variable Precedence
1. Role defaults (`roles/*/defaults/main.yml`)
2. Inventory group_vars (`inventories/*/group_vars/*.yml`)
3. Inventory host_vars (`inventories/*/host_vars/*.yml`)
4. Extra vars (`-e` on command line)

## Code Conventions

- All modules use Fully Qualified Collection Names (FQCNs): `community.general.pacman`, `ansible.builtin.file`
- Required collections: `community.general >=8.0`, `ansible.posix >=1.5`
- Tasks tagged for selective execution (`--tags partitioning`, `--skip-tags bootloader`)
- AUR packages use `become_user` to run as non-root

## Safety Features

- Installation detects existing system via `/mnt/etc/arch-release`
- Repartitioning requires explicit `arch_install_force_repartition: true`
- 10-second pause before destructive operations
- State marker at `/mnt/root/.ansible-stage0-done`
