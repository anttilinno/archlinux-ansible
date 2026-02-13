# Configuration

## Installation Variables

Set in `inventories/install/group_vars/all.yml` or pass with `-e`.

### Hardware

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_disk` | `/dev/sda` | Target disk device |
| `arch_install_cpu` | `intel` | CPU type: `intel`, `amd`, or `none` |
| `arch_install_gpu` | `intel` | GPU type: `intel`, `amd`, `nvidia`, or `none` |
| `arch_install_boot_mode` | `bios` | Boot mode: `bios` or `uefi` |
| `arch_install_wifi` | `true` | Install wifi packages |

**Note**: `nvidia` GPU option includes mesa for Optimus support and uses `nvidia-lts` to match the LTS kernel.

### System

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_hostname` | `archbox` | System hostname |
| `arch_install_locale` | `en_US.UTF-8` | System locale |
| `arch_install_timezone` | `Europe/Tallinn` | Timezone |
| `arch_install_keymap` | `us` | Console keymap |

### User

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_admin_user` | `antti` | Admin username |
| `arch_install_admin_shell` | `/bin/zsh` | Admin user shell |
| `arch_install_admin_pubkey` | Auto-detected | SSH public key |

### Partitioning

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_swap_size` | `4GiB` | Swap partition size |
| `arch_install_efi_size` | `512MiB` | EFI partition size (UEFI only) |
| `arch_install_root_fs_label` | `archroot` | Root filesystem label |
| `arch_install_force_repartition` | `false` | Force repartition existing disk |

### Mirrors

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_reflector_countries` | Estonia, Finland, Sweden, Latvia, Lithuania | Mirror countries |
| `arch_install_skip_mirror_refresh` | `false` | Skip mirror refresh |

### Behavior

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_install_perform_reboot` | `true` | Reboot after installation |
| `arch_install_reboot_timeout` | `180` | Reboot timeout in seconds |

## Provisioning Variables

Set in `inventories/provision/group_vars/all.yml`. Inventory files are gitignored — copy from `*.example` templates first.

### Machine Type

| Variable | Default | Options |
|----------|---------|---------|
| `machine_type` | `laptop` | `laptop`, `desktop` |

### Package Groups

| Variable | Default | Packages |
|----------|---------|----------|
| `common_cli_enabled` | `true` | zoxide, fzf, fd, eza, bat, ripgrep, less, jq, unzip, btop, cyme |
| `common_shell_enabled` | `true` | zsh, starship |
| `common_git_enabled` | `true` | git, lazygit, github-cli |
| `common_filemanager_enabled` | `true` | yazi, ffmpeg, 7zip, resvg, imagemagick, chafa |
| `common_terminal_enabled` | `true` | tmux |
| `common_fonts_enabled` | `true` | ttf-jetbrains-mono-nerd, ttf-nerd-fonts-symbols-mono, noto-fonts-emoji |
| `common_dev_enabled` | `false` | chezmoi, stylua, shfmt, luarocks, xh, nodejs, npm, pnpm |
| `common_docker_enabled` | `false` | docker, docker-compose, lazydocker |
| `common_devops_enabled` | `false` | aws-cli-v2, kubectl, helm, kubeseal, opentofu-bin |
| `common_audio_enabled` | `false` | pipewire, pipewire-pulse, wireplumber, alsa-utils, pavucontrol |
| `common_bluetooth_enabled` | `false` | bluez, bluez-utils, blueman |
| `common_i3_enabled` | `false` | xorg-server, xorg-xinit, i3-wm, polybar, rofi, wezterm, xclip, flameshot |
| `common_virt_enabled` | `false` | qemu-desktop, libvirt, virt-manager, dnsmasq, edk2-ovmf |
| `common_office_enabled` | `false` | audacity, libreoffice-fresh, obsidian-bin, slack-desktop |
| `common_aur_enabled` | `false` | shellcheck-bin, i3lock-color, zen-browser-bin |

## Task Runner Commands

Using mise on the target system:

```bash
mise run install      # Install Ansible collections
mise run provision    # Run provisioning
mise run check        # Dry-run provisioning
mise run lint         # Run yamllint and ansible-lint
mise run test         # Run all quality checks
mise run ping         # Test connectivity
mise run clean        # Clean temp files
```

## Tags

Control execution with `--tags` or `--skip-tags`:

### Installation tags

- `sanity_checks` - Pre-flight validation
- `partitioning` - Disk partitioning
- `mount` - Filesystem mounting
- `mirrors` - Mirror configuration
- `pacstrap` - Base system installation
- `configure` - System configuration
- `users` - User setup
- `services` - Service enablement
- `bootloader` - Bootloader installation
- `finalize` - Cleanup and reboot

### Provisioning tags

- `common` / `baseline` - All common role tasks

## Examples

### Install with custom disk

```bash
./run.sh install -e "arch_install_disk=/dev/nvme0n1"
```

### Install UEFI system with AMD GPU

```bash
./run.sh install -e "arch_install_boot_mode=uefi arch_install_gpu=amd"
```

### Force repartition

```bash
./run.sh install -e "arch_install_force_repartition=true"
```

### Provision with specific tags

```bash
mise run provision -- --tags docker
```

### Dry-run provisioning

```bash
mise run check
```
