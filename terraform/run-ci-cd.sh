#!/usr/bin/env bash
set -euo pipefail


#  
#terraform init -reconfigure


# 1. Terraform init & apply
terraform init 
terraform apply -auto-approve

# 2. Capture IPs as JSON
JENKINS_IP=$(terraform output -json jenkins_public_ip | jq -r .)
NEXUS_IP=$(terraform output -json nexus_public_ip | jq -r .)
SONARQUBE_IP=$(terraform output -json sonarqube_public_ip | jq -r .)

# 3. Generate dynamic Ansible inventory
cat > ../Ansible/inventory <<EOF
[jenkins]
jenkins-server ansible_host=${JENKINS_IP} ansible_user=ec2-user

[sonarqube]
sonarqube-server ansible_host=${SONARQUBE_IP} ansible_user=ec2-user

[nexus]
nexus-server ansible_host=${NEXUS_IP} ansible_user=ec2-user

[all:vars]
ansible_ssh_private_key_file=../terraform/board-game-key.pem
EOF

echo "Generated inventory file:"
cat ../Ansible/inventory

# 4. Run Ansible playbook
cd ../Ansible
ansible-playbook -i inventory installation.yml
