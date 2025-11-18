# Custom Modules

This directory contains custom Ansible modules for specialized tasks not covered by built-in or collection modules.

## Usage

Place Python module files in this directory. Ansible will automatically discover and load them.

## Example

```python
#!/usr/bin/python
# my_module.py

from ansible.module_utils.basic import AnsibleModule

def main():
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(type='str', required=True),
        )
    )
    
    # Module logic here
    result = dict(
        changed=False,
        message='Hello ' + module.params['name']
    )
    
    module.exit_json(**result)

if __name__ == '__main__':
    main()
```

Use in playbooks:
```yaml
- name: Use custom module
  my_module:
    name: World
```

## Documentation

- [Ansible Module Development](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html)

