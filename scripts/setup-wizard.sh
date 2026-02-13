#!/bin/bash
set -euo pipefail

PROVISION_DIR="inventories/provision"

# --- helpers ---

ask() {
  local prompt="$1" default="$2" reply
  read -rp "$prompt [$default]: " reply
  echo "${reply:-$default}"
}

ask_yn() {
  local prompt="$1" default="$2" reply
  if [[ "$default" == "true" ]]; then
    read -rp "$prompt [Y/n]: " reply
    [[ "${reply,,}" != "n" ]] && echo "true" || echo "false"
  else
    read -rp "$prompt [y/N]: " reply
    [[ "${reply,,}" == "y" ]] && echo "true" || echo "false"
  fi
}

# --- check existing files ---

existing_files=()
[[ -f "$PROVISION_DIR/hosts.ini" ]] && existing_files+=("$PROVISION_DIR/hosts.ini")
[[ -f "$PROVISION_DIR/group_vars/all.yml" ]] && existing_files+=("$PROVISION_DIR/group_vars/all.yml")
for f in "$PROVISION_DIR"/host_vars/*.yml; do
  [[ -f "$f" ]] && existing_files+=("$f")
done

if [[ ${#existing_files[@]} -gt 0 ]]; then
  echo "Existing inventory files found:"
  printf "  - %s\n" "${existing_files[@]}"
  echo ""
  echo "  b) Backup and overwrite"
  echo "  o) Overwrite without backup"
  echo "  q) Quit"
  read -rp "Choose [b/o/q]: " choice
  case "${choice,,}" in
    b)
      backup_dir="$PROVISION_DIR/backup-$(date +%Y%m%d-%H%M%S)"
      mkdir -p "$backup_dir/group_vars" "$backup_dir/host_vars"
      for f in "${existing_files[@]}"; do
        rel="${f#"$PROVISION_DIR/"}"
        cp "$f" "$backup_dir/$rel"
      done
      echo "Backed up to $backup_dir/"
      ;;
    o) ;;
    *) echo "Aborted." && exit 0 ;;
  esac
fi

# --- gather info ---

echo ""
echo "=== Host setup ==="
hostname=$(ask "Hostname" "$(hostname)")
machine_type=$(ask "Machine type (laptop/desktop)" "laptop")
username=$(ask "Admin username" "${SUDO_USER:-${USER}}")

echo ""
echo "=== Package groups ==="
echo "(Enter to accept default, y/n to toggle)"
echo ""

cli=$(ask_yn      "  CLI tools (zoxide, fzf, bat, ripgrep, btop...)" "true")
shell=$(ask_yn    "  Shell (zsh, starship)" "true")
git=$(ask_yn      "  Git tools (git, lazygit, github-cli)" "true")
fm=$(ask_yn       "  File manager (yazi)" "true")
terminal=$(ask_yn "  Terminal multiplexer (tmux)" "true")
fonts=$(ask_yn    "  Fonts (JetBrains Mono Nerd, Noto emoji)" "true")
dev=$(ask_yn      "  Development tools (chezmoi, stylua, nodejs...)" "false")
docker=$(ask_yn   "  Docker (docker, docker-compose, lazydocker)" "false")
devops=$(ask_yn   "  DevOps (aws-cli, kubectl, helm, opentofu)" "false")
audio=$(ask_yn    "  Audio (pipewire, wireplumber, pavucontrol)" "false")
bluetooth=$(ask_yn "  Bluetooth (bluez, blueman)" "false")
i3=$(ask_yn       "  i3 window manager (xorg, i3, polybar, rofi)" "false")
virt=$(ask_yn     "  Virtualization (qemu, libvirt, virt-manager)" "false")
office=$(ask_yn   "  Office (audacity, libreoffice, obsidian, slack)" "false")
aur=$(ask_yn      "  AUR extras (shellcheck, i3lock-color, zen-browser)" "false")

# --- generate files ---

mkdir -p "$PROVISION_DIR/group_vars" "$PROVISION_DIR/host_vars"

cat > "$PROVISION_DIR/hosts.ini" <<EOF
# Post-install provisioning inventory
[${machine_type}s]
${hostname} ansible_host=127.0.0.1 ansible_connection=local
EOF

cat > "$PROVISION_DIR/host_vars/${hostname}.yml" <<EOF
ansible_user: ${username}
ansible_become: true
EOF

cat > "$PROVISION_DIR/group_vars/all.yml" <<EOF
---
# Machine type: laptop or desktop
machine_type: ${machine_type}

# Post-install package configuration
# Edit true/false to enable/disable package groups

# CLI tools (zoxide, fzf, fd, eza, bat, ripgrep, less, jq, unzip, btop, cyme)
common_cli_enabled: ${cli}

# Shell (zsh, starship)
common_shell_enabled: ${shell}

# Git tools (git, lazygit, github-cli)
common_git_enabled: ${git}

# File manager (yazi + deps)
common_filemanager_enabled: ${fm}

# Terminal multiplexer (tmux)
common_terminal_enabled: ${terminal}

# Fonts (jetbrains-mono-nerd, nerd-fonts-symbols, noto-emoji)
common_fonts_enabled: ${fonts}

# Development tools (chezmoi, stylua, shfmt, luarocks, xh)
common_dev_enabled: ${dev}

# Docker (docker, docker-compose, lazydocker)
common_docker_enabled: ${docker}

# DevOps tools (aws-cli-v2, kubectl, helm, kubeseal, opentofu-bin)
common_devops_enabled: ${devops}

# Audio/pipewire (pipewire, pipewire-pulse, wireplumber, alsa-utils)
common_audio_enabled: ${audio}

# Bluetooth (bluez, bluez-utils, blueman)
common_bluetooth_enabled: ${bluetooth}

# i3 window manager (xorg, i3-wm, polybar, rofi, wezterm, xclip, flameshot)
common_i3_enabled: ${i3}

# Virtualization (qemu-desktop, libvirt, virt-manager, dnsmasq, edk2-ovmf)
common_virt_enabled: ${virt}

# Office/productivity apps (audacity, libreoffice, obsidian, slack)
common_office_enabled: ${office}

# AUR packages (shellcheck-bin, i3lock-color, zen-browser-bin)
common_aur_enabled: ${aur}
EOF

echo ""
echo "Generated:"
echo "  $PROVISION_DIR/hosts.ini"
echo "  $PROVISION_DIR/group_vars/all.yml"
echo "  $PROVISION_DIR/host_vars/${hostname}.yml"
echo ""
echo "Run 'mise run provision' to apply."
