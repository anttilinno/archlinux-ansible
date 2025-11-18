# Filter Plugins

This directory contains custom Jinja2 filter plugins for use in playbooks and templates.

## Usage

Place Python files in this directory to define custom filters. Ansible will automatically load them.

## Example

```python
# custom_filters.py
def reverse_string(s):
    return s[::-1]

class FilterModule(object):
    def filters(self):
        return {
            'reverse': reverse_string
        }
```

Use in templates or playbooks:
```yaml
- debug:
    msg: "{{ 'hello' | reverse }}"
```

## Documentation

- [Ansible Filter Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#filter-plugins)

