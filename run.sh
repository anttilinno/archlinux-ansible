#!/bin/bash
# Simple wrapper for ansible-playbook

cd "$(dirname "$0")" || exit 1

case "${1:-site}" in
  install)
    # Stage 0: Install from live ISO
    ANSIBLE_HOST_KEY_CHECKING=False \
    ansible-playbook -i inventories/install/hosts.ini playbooks/install-arch.yml --ask-pass "${@:2}"
    ;;
  site|"")
    # Stage 1: Post-install provisioning (default)
    ansible-playbook -i inventories/provision/hosts.ini site.yml "${@:2}"
    ;;
  *)
    echo "Usage: $0 [install|site] [extra ansible args]"
    echo ""
    echo "  install  - Run from live ISO (stage 0)"
    echo "  site     - Post-install provisioning (default)"
    echo ""
    echo "Examples:"
    echo "  $0                              # Run site.yml"
    echo "  $0 site --tags docker           # Only docker tasks"
    echo "  $0 install -e arch_install_disk=/dev/vda"
    exit 1
    ;;
esac
