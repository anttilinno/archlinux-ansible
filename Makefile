.PHONY: help install lint syntax check test install-arch provision ping clean

# Default target
help:
	@echo "Ansible T60 Management Commands"
	@echo "================================"
	@echo ""
	@echo "Setup:"
	@echo "  make install         Install Ansible and required collections"
	@echo ""
	@echo "Quality Checks:"
	@echo "  make lint            Run ansible-lint and yamllint"
	@echo "  make syntax          Check playbook syntax"
	@echo "  make check           Run playbooks in check mode (dry run)"
	@echo ""
	@echo "Deployment:"
	@echo "  make install-arch    Run Arch installation (DESTRUCTIVE)"
	@echo "  make provision       Run post-install provisioning"
	@echo "  make ping            Test connectivity to hosts"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           Clean temporary files and caches"
	@echo ""

# Install Ansible and dependencies
install:
	@echo "Installing Ansible and dependencies..."
	ansible-galaxy install -r requirements.yml

# Run linters
lint:
	@echo "Running yamllint..."
	yamllint .
	@echo ""
	@echo "Running ansible-lint..."
	ansible-lint

# Check syntax
syntax:
	@echo "Checking playbook syntax..."
	ansible-playbook --syntax-check playbooks/install-arch-t60.yml
	ansible-playbook --syntax-check site.yml

# Check mode (dry run)
check:
	@echo "Running playbooks in check mode (dry run)..."
	@echo "Note: Some tasks may fail in check mode"
	ansible-playbook -i inventories/prod/hosts.ini --check site.yml || true

# Test connectivity
ping:
	@echo "Testing connectivity to prod hosts..."
	ansible -i inventories/prod/hosts.ini all -m ansible.builtin.ping

# Run Arch installation (WARNING: DESTRUCTIVE)
install-arch:
	@echo "WARNING: This will partition and format the target disk!"
	@echo "Press Ctrl+C within 5 seconds to abort..."
	@sleep 5
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook -i inventories/lab/hosts.ini \
	  playbooks/install-arch-t60.yml \
	  --ask-pass

# Run post-install provisioning
provision:
	@echo "Running post-install provisioning..."
	ansible-playbook -i inventories/prod/hosts.ini site.yml

# Run provisioning in check mode
provision-check:
	@echo "Running post-install provisioning in check mode..."
	ansible-playbook -i inventories/prod/hosts.ini site.yml --check

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	find . -name "*.retry" -delete
	rm -rf .cache/
	rm -rf ~/.ansible/facts_cache/*
	@echo "Clean complete!"

# Run all quality checks
test: syntax lint
	@echo "All quality checks passed!"

