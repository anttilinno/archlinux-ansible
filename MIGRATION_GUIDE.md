# Migration Guide: Refactored Structure

This guide explains the changes made to refactor the Ansible repository according to industry best practices.

## Summary of Changes

The monolithic 381-line `playbooks/install-arch-t60.yml` has been refactored into a modular, role-based architecture following Ansible best practices.

## Before and After

### Before
```
ansible-t60/
├── playbooks/
│   └── install-arch-t60.yml  (381 lines with everything embedded)
├── roles/
│   └── common/               (minimal stub)
└── site.yml                  (basic)
```

### After
```
ansible-t60/
├── playbooks/
│   ├── install-arch-t60.yml  (50 lines, uses arch_install role)
│   └── README.md
├── roles/
│   ├── arch_install/         (NEW - complete installation role)
│   │   ├── defaults/         (all variables)
│   │   ├── tasks/            (10 modular task files)
│   │   ├── handlers/         (bootloader handler)
│   │   ├── meta/             (role metadata)
│   │   └── README.md
│   └── common/               (enhanced with proper structure)
├── site.yml                  (enhanced)
└── Documentation files       (comprehensive)
```

## Key Improvements

### 1. Role-Based Architecture
**Old**: All tasks in a single playbook  
**New**: Dedicated `arch_install` role with modular structure

**Benefits**:
- Reusable across different playbooks
- Easier to test individual components
- Better organization and maintainability

### 2. Modular Task Files
**Old**: 381 lines in one file  
**New**: 10 focused task files

Task breakdown:
- `sanity_checks.yml` - Pre-flight validation
- `partitioning.yml` - Disk operations
- `mount.yml` - Filesystem mounting
- `mirrors.yml` - Package mirror configuration
- `pacstrap.yml` - Base system installation
- `configure_system.yml` - Locale, timezone, hostname
- `users.yml` - User and authentication setup
- `services.yml` - Service enablement
- `bootloader.yml` - Syslinux installation
- `finalize.yml` - Cleanup and reboot

**Benefits**:
- Easier to navigate and understand
- Can be tested independently
- Selective execution with tags

### 3. Variable Management
**Old**: Variables embedded in playbook  
**New**: Proper variable hierarchy

```
Role defaults       → roles/arch_install/defaults/main.yml
Group variables     → inventories/{lab,prod}/group_vars/all.yml
Playbook overrides  → In playbook vars or -e flags
```

**Benefits**:
- Clear variable precedence
- Easy to override for different environments
- No need to edit role files for customization

### 4. Fully Qualified Collection Names (FQCNs)
**Old**: Mixed (e.g., `copy`, `lineinfile`)  
**New**: All use FQCNs (e.g., `ansible.builtin.copy`)

**Benefits**:
- Future-proof against module namespace conflicts
- Explicit about module sources
- Ansible 2.10+ best practice

### 5. Enhanced Error Handling
**Old**: Basic error handling  
**New**: Block/rescue patterns for critical sections

Example:
```yaml
- name: Partitioning block
  block:
    # Partitioning tasks
  rescue:
    - name: Partitioning failed
      ansible.builtin.fail:
        msg: "Partitioning failed. Check disk status."
```

**Benefits**:
- Better error messages
- Graceful failure handling
- Easier debugging

### 6. Comprehensive Documentation
**New files**:
- `README.md` - Project overview
- `CONTRIBUTING.md` - Development guidelines
- `VERIFICATION.md` - Best practices checklist
- `MIGRATION_GUIDE.md` - This file
- Role READMEs - Detailed role documentation
- Directory READMEs - Purpose and usage

### 7. Quality Assurance Tools
**New files**:
- `.ansible-lint` - Ansible linting rules
- `.yamllint` - YAML style rules
- `.gitignore` - Ignore patterns
- `Makefile` - Common operations

### 8. Enhanced ansible.cfg
**Improvements**:
- Fact caching enabled
- Connection optimization (pipelining)
- Better output formatting
- Performance tuning

## Variable Name Changes

All variables are now prefixed with the role name:

| Old Variable | New Variable |
|-------------|--------------|
| `disk` | `arch_install_disk` |
| `root_fs_label` | `arch_install_root_fs_label` |
| `hostname` | `arch_install_hostname` |
| `locale` | `arch_install_locale` |
| `timezone` | `arch_install_timezone` |
| `admin_user` | `arch_install_admin_user` |
| `admin_shell` | `arch_install_admin_shell` |
| `admin_pubkey` | `arch_install_admin_pubkey` |
| `force_repartition` | `arch_install_force_repartition` |
| `state_marker` | `arch_install_state_marker` |
| `desired_pkgset` | `arch_install_base_packages` |
| `packages_common` | `common_packages` |

## Usage Changes

### Running Installation

**Old**:
```bash
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml --ask-pass
```

**New** (same command, improved internals):
```bash
# Same command works!
make install-arch

# Or manually:
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventories/lab/hosts.ini \
  playbooks/install-arch-t60.yml --ask-pass
```

### Running Provisioning

**Old**:
```bash
ansible-playbook -i inventories/prod/hosts.ini site.yml
```

**New** (same command, enhanced):
```bash
# Same command works!
make provision

# Or manually:
ansible-playbook -i inventories/prod/hosts.ini site.yml
```

### New Capabilities

**Selective execution with tags**:
```bash
# Run only partitioning
ansible-playbook ... --tags partitioning

# Skip bootloader
ansible-playbook ... --skip-tags bootloader

# Multiple tags
ansible-playbook ... --tags "configure,users"
```

**Quality checks**:
```bash
make lint     # Run linters
make syntax   # Check syntax
make check    # Dry run
make test     # All quality checks
```

**Quick operations**:
```bash
make ping     # Test connectivity
make clean    # Clean temporary files
```

## Customization

### Overriding Variables

**Method 1: Group Variables** (recommended)
```yaml
# inventories/lab/group_vars/all.yml
arch_install_hostname: my-laptop
arch_install_disk: /dev/nvme0n1
```

**Method 2: Command Line**
```bash
ansible-playbook ... -e "arch_install_hostname=my-laptop"
```

**Method 3: Playbook Variables**
```yaml
# playbooks/install-arch-t60.yml
- name: Install Arch Linux
  hosts: t60_iso
  roles:
    - role: arch_install
      arch_install_hostname: my-laptop
```

## Backward Compatibility

The refactored playbook maintains the same external interface:
- ✓ Same command-line usage
- ✓ Same vars_prompt for password
- ✓ Same overall behavior
- ✓ Improved internal structure

**What's NOT backward compatible**:
- Variable names (but easily overridden)
- Direct playbook editing (use role defaults/group_vars instead)

## Testing the New Structure

1. **Syntax check**:
   ```bash
   make syntax
   ```

2. **Lint check**:
   ```bash
   make lint
   ```

3. **Check mode** (dry run on prod):
   ```bash
   make provision-check
   ```

4. **Test in lab environment first**:
   ```bash
   # Use lab inventory for testing
   ansible-playbook -i inventories/lab/hosts.ini --check playbooks/install-arch-t60.yml
   ```

## Rollback

If needed, the original playbook is preserved in Git history:
```bash
git log --oneline playbooks/install-arch-t60.yml
git show <commit-hash>:playbooks/install-arch-t60.yml > old-playbook.yml
```

## Next Steps

1. Review the new structure and documentation
2. Test in a safe environment (VM or spare hardware)
3. Customize variables in `inventories/*/group_vars/`
4. Add additional roles as needed
5. Extend the `common` role with your specific requirements

## Questions?

Refer to:
- `README.md` - General usage
- `roles/arch_install/README.md` - Installation role details
- `CONTRIBUTING.md` - Development guidelines
- `VERIFICATION.md` - Best practices verification

## Summary

This refactoring transforms a monolithic playbook into a professional, maintainable, and extensible Ansible project that follows all industry best practices while maintaining the same functionality and user interface.

