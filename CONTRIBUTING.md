# Contributing Guidelines

## Ansible Best Practices

This project follows industry-standard Ansible best practices. When contributing, please adhere to the following guidelines:

### Directory Structure

Follow the standard Ansible project layout:
```
roles/
  role_name/
    defaults/      # Default variables (lowest precedence)
    vars/          # Role variables (higher precedence)
    tasks/         # Task files
    handlers/      # Handlers
    templates/     # Jinja2 templates
    files/         # Static files
    meta/          # Role metadata and dependencies
```

### Variable Naming

- Use descriptive, lowercase names with underscores
- Prefix role variables with the role name (e.g., `arch_install_disk`)
- Use `_list` suffix for lists, `_dict` for dictionaries
- Document all variables in role defaults with comments

### Module Usage

- Always use Fully Qualified Collection Names (FQCNs):
  - Good: `ansible.builtin.copy`
  - Bad: `copy`
- Prefer native Ansible modules over `shell`/`command` when possible
- Use `changed_when` and `failed_when` with `command`/`shell` modules
- Set `check_mode: false` for read-only operations

### Task Organization

- Break large playbooks into roles
- Break large task files into smaller, focused files
- Use `import_tasks` for static includes, `include_tasks` for dynamic
- Group related tasks with `block` and add `rescue` for error handling
- Use meaningful task names that describe the action

### Idempotency

- Tasks should be safe to run multiple times
- Use appropriate modules that handle idempotency natively
- Test playbooks in check mode: `ansible-playbook --check`

### Tags

Apply tags to enable selective execution:
```yaml
- name: Task name
  module:
    param: value
  tags:
    - category
    - specific_feature
```

### Handlers

- Place handlers in `handlers/main.yml`
- Name handlers with action verbs (e.g., "Restart service")
- Handlers should be notified, not called directly

### Security

- Never commit secrets, passwords, or keys
- Use Ansible Vault for sensitive data
- Set `no_log: true` for tasks handling sensitive information
- Lock down file permissions appropriately

### Documentation

- Add README.md to all roles
- Document all variables in role defaults
- Include usage examples in role README
- Keep main README.md up to date

### Code Quality

Before submitting, run:
```bash
# Check YAML syntax
yamllint .

# Check Ansible best practices
ansible-lint

# Test in check mode
ansible-playbook --check playbook.yml

# Verify syntax
ansible-playbook --syntax-check playbook.yml
```

### Git Workflow

1. Create a feature branch
2. Make focused commits with clear messages
3. Test your changes thoroughly
4. Submit a pull request with description

### Commit Messages

Use clear, descriptive commit messages:
```
Add SSH hardening to common role

- Disable root login
- Configure fail2ban
- Set up SSH key-only auth
```

## Testing

Test all changes in a safe environment before applying to production:

1. **Syntax check**: `ansible-playbook --syntax-check playbook.yml`
2. **Dry run**: `ansible-playbook --check playbook.yml`
3. **Limited scope**: `ansible-playbook --limit test_host playbook.yml`
4. **Verbose mode**: `ansible-playbook -vvv playbook.yml`

## Code Style

- YAML: 2-space indentation
- Maximum line length: 120 characters (where reasonable)
- Use single quotes for strings unless interpolation needed
- Boolean values: `true`/`false` or `yes`/`no` (be consistent)
- Lists: prefer block style over inline

Good:
```yaml
packages:
  - vim
  - htop
  - git
```

Acceptable for short lists:
```yaml
flags: [boot]
```

## Questions?

Open an issue for questions or clarification on contribution guidelines.

