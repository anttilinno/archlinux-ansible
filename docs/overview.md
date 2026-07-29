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
**Roles**: `common`, `laptop`, `wayland`, `tablet`, `esp32`, `gaming`, `ollama`, `kodi`
**Inventory**: `inventories/provision/`

Roles run in the order listed above. Each is gated by its own `*_enabled`
variables, so a role with everything disabled costs only skipped tasks.

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
    ├── arch_install/     # Stage 0: bare metal installation
    ├── common/           # Packages and services shared by every machine
    ├── laptop/           # Battery charge limiting
    ├── wayland/          # niri compositor, bar, utilities, DMS shell
    ├── tablet/           # OpenTabletDriver for Huion/UGEE tablets
    ├── esp32/            # Arduino CLI and serial port access
    ├── gaming/           # Steam, Wine, performance tools
    ├── ollama/           # Local LLM runtime (CPU or CUDA)
    └── kodi/             # Media centre
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

Also bootstraps `yay` itself: it compares the installed `yay-bin` version
against the AUR RPC and rebuilds only on a mismatch. Every other role's AUR
tasks depend on this having run.

### laptop

Caps battery charge to preserve longevity on machines that mostly run on AC.
Writes the sysfs charge threshold (ThinkPad-style). Off by default; set
`laptop_battery_charge_limit_enabled` and `laptop_battery` (default `BAT0`).

### wayland

The desktop. `wayland_niri_enabled` brings the compositor plus XWayland;
`wayland_bar_enabled` adds waybar; `wayland_utils_enabled` covers the launcher,
terminal, screenshot and clipboard tools. `wayland_dms_enabled` (on by default)
installs Dank Material Shell, a Quickshell-based shell, and enables
`dms.service` via `systemctl --global`. `wayland_autologin_enabled` starts niri
on tty1 through getty autologin, written to both `.bash_profile` and `.zprofile`.

### tablet

OpenTabletDriver for graphics tablets and keydials — Huion and other UGEE-built
hardware (KD100, HS610, and the rest of OTD's supported list). Off by default.

Two things make this role less trivial than it looks:

- The AUR build needs the .NET runtime whose major version matches the
  installed SDK. Arch's `dotnet-runtime-8.0` declares `provides=dotnet-runtime`,
  so pacman treats `dotnet-sdk`'s dependency as satisfied and never pulls the
  current runtime. The role installs `dotnet-runtime` explicitly.
- The kernel's `hid_uclogic` driver claims these tablets and sends fixed,
  unrebindable keystrokes. OTD ships a modprobe.d file to stop it loading, but
  that only applies at the next boot. The role unloads the module so the device
  rebinds to `hid-generic` and OTD can take raw HID access immediately.

Per-device configuration (key bindings, dial, mapped area) is **not** managed
here — it lives in `~/.config/OpenTabletDriver/`, written by the `otd` CLI or
the GUI.

### esp32

Arduino CLI, `python-pyserial` and `udisks2`, plus serial group membership for
`esp32_user`. On by default.

### gaming

Enables the multilib repository, then installs Steam and Vulkan
(`gaming_steam_enabled`), gamemode and mangohud (`gaming_performance_enabled`),
Wine (`gaming_wine_enabled`), 32-bit NVIDIA libraries (`gaming_nvidia_enabled`)
and AUR extras such as Heroic and ProtonUp-Qt (`gaming_aur_enabled`). All off by
default. The AUR group imports the GPG keys listed in `gaming_aur_gpg_keys`.

### ollama

Local LLM runtime. `ollama_enabled` installs the CPU build from the official
repo; `ollama_cuda_enabled` installs `ollama-cuda` from the AUR instead, for
NVIDIA GPUs. Both off by default.

### kodi

Media centre, with optional media codecs, addons, USB automount via udiskie,
and autologin into i3 on tty1. All groups off by default.

## Package Groups

Each group can be toggled independently.

### common

| Group | Packages |
|-------|----------|
| `common_cli_enabled` | zoxide, fzf, fd, eza, bat, ripgrep, jq, btop, worktrunk |
| `common_shell_enabled` | zsh, starship |
| `common_git_enabled` | git, lazygit, github-cli |
| `common_filemanager_enabled` | yazi + dependencies |
| `common_terminal_enabled` | tmux |
| `common_fonts_enabled` | JetBrains Mono Nerd, Noto emoji |
| `common_dev_enabled` | stylua, shfmt, luarocks, xh, nodejs, npm, pnpm, atuin, uv (+ AUR: claude-code) |
| `common_docker_enabled` | docker, docker-compose, lazydocker |
| `common_audio_enabled` | pipewire, wireplumber, alsa-utils |
| `common_i3_enabled` | xorg, i3-wm, polybar, rofi, wezterm (+ AUR: xkb-switch, i3lock-color) |
| `common_bluetooth_enabled` | bluez, bluez-utils, blueman |
| `common_devops_enabled` | aws-cli-v2, kubectl, helm, kubeseal, opentofu-bin |
| `common_virt_enabled` | qemu-desktop, libvirt, virt-manager, dnsmasq, edk2-ovmf |
| `common_office_enabled` | audacity, libreoffice, obsidian, slack |
| `common_aur_enabled` | shellcheck-bin, zen-browser |
| `common_keyring_enabled` | gnome-keyring, libsecret (Secret Service) |
| `common_laptop_enabled` | networkmanager, wpa_supplicant, brightnessctl |

### wayland

| Group | Default | Packages |
|-------|---------|----------|
| `wayland_niri_enabled` | on | niri, xorg-xwayland, xwayland-satellite, xdg-desktop-portal-gnome |
| `wayland_bar_enabled` | on | waybar |
| `wayland_utils_enabled` | on | fuzzel, foot, grim, slurp, satty, wl-clipboard, wpaperd, swaylock |
| `wayland_zathura_enabled` | on | zathura, zathura-pdf-poppler, xournalpp, krita |
| `wayland_dms_enabled` | on | quickshell, dgop, cava, ddcutil, cliphist, qt6ct, wtype, … (+ AUR: dms-shell-git, matugen-bin, ttf-material-symbols-variable-git) |
| `wayland_autologin_enabled` | off | none — configures getty autologin on tty1 |

### Other roles

| Group | Default | Packages |
|-------|---------|----------|
| `tablet_enabled` | off | dotnet-runtime (+ AUR: opentabletdriver) |
| `tablet_service_enabled` | on | none — enables the per-user `opentabletdriver.service` |
| `laptop_battery_charge_limit_enabled` | off | none — writes the sysfs charge threshold |
| `esp32_enabled` | on | arduino-cli, python-pyserial, udisks2 |
| `gaming_steam_enabled` | off | steam, lib32-vulkan-icd-loader, lib32-mesa |
| `gaming_performance_enabled` | off | gamemode, mangohud, lib32-mangohud |
| `gaming_wine_enabled` | off | wine, wine-mono, wine-gecko, winetricks |
| `gaming_nvidia_enabled` | off | lib32-nvidia-utils |
| `gaming_aur_enabled` | off | heroic-games-launcher-bin, protonup-qt, game-devices-udev |
| `ollama_enabled` | off | ollama (CPU build) |
| `ollama_cuda_enabled` | off | ollama-cuda (AUR, NVIDIA) |
| `kodi_enabled` | off | kodi |
| `kodi_media_enabled` | off | mpv, gst-plugins-bad, gst-plugins-ugly |
| `kodi_addons_enabled` | off | kodi-addon-inputstream-adaptive, kodi-addon-peripheral-joystick |
| `kodi_aur_enabled` | off | zen-browser-bin |
| `kodi_automount_enabled` | off | udisks2, udiskie |
| `kodi_autologin_enabled` | off | none — configures getty autologin into i3 |

## Development

```bash
mise run install    # collections into ~/.ansible/collections
mise run test       # syntax check + yamllint + ansible-lint
```

`mise run install` must be run before `mise run test` on a new machine. Arch's
`ansible` package bundles `community.general` inside site-packages, which the
playbooks can use but `ansible-lint` cannot see — it runs its own isolated
`ansible-core`. The task therefore installs into `~/.ansible/collections`
explicitly, with `--force` (without it, galaxy finds the site-packages copy and
reports "Nothing to do").

`ansible-lint` runs in offline mode. Leave it that way: online, it runs its own
`ansible-galaxy collection install` and leaves a stub that shadows the real
collection. For the same reason `mock_modules` in `.ansible-lint` must stay
empty — see [Roadmap](roadmap.md).

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
