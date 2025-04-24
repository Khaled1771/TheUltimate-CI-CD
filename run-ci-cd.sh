#!/usr/bin/env bash
set -euo pipefail

# 1. Terraform init & apply
terraform init
terraform apply -auto-approve

# 2. Capture IPs as JSON
read -r JENKINS_IP NEXUS_IP SONARQUBE_IP < <(
  terraform output -json jenkins_public_ip   | jq -r .
  terraform output -json nexus_public_ip     | jq -r .
  terraform output -json sonarqube_public_ip | jq -r .
)

# 3. Generate dynamic Ansible inventory
cat > Ansible/inventory.yml <<EOF
all:
  hosts:
    jenkins:
      ansible_host: ${JENKINS_IP}
    nexus:
      ansible_host: ${NEXUS_IP}
    sonarqube:
      ansible_host: ${SONARQUBE_IP}
  vars:
    ansible_user: ubuntu                       # change if needed
    ansible_ssh_private_key_file: ~/.ssh/id_rsa.pem
EOF

echo "Generated inventory.yml:"
cat inventory.yml

# 4. Run Ansible playbook
ansible-playbook -i inventory.yml ansible/installation.yml
