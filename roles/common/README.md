# Common Role

## Description

Common baseline configuration tasks for all systems. This role applies system-wide settings and ensures standard packages are installed.

## Requirements

- Ansible >= 2.14
- System already has base Arch Linux installation

## Role Variables

Available in `defaults/main.yml`:
- `common_packages`: List of common packages to install (default: defined in defaults)

## Dependencies

None

## Example Playbook

```yaml
---
- name: Apply common configuration
  hosts: all
  become: true
  
  roles:
    - role: common
```

## License

MIT

## Author

Antti

