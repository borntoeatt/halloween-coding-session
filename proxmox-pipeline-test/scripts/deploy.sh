#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# CONFIG
# ------------------------------
PROXMOX_IP="192.168.0.100"
PROXMOX_SSH="${SSH_USER}@${PROXMOX_IP}"
SSH_OPTS="-i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$BASE_DIR/terraform"
ANSIBLE_DIR="$BASE_DIR/ansible"
INVENTORY_FILE="$BASE_DIR/inventory.ini"
MAX_RETRIES=30
SLEEP_INTERVAL=5

# ------------------------------
# ROLE ARGUMENTS
# ------------------------------
IFS=',' read -ra SELECTED_ROLES <<< "${1:-all}"
all_containers=(testbox nextcloud grafana jenkins influxdb)

# Validate roles
if [[ "${SELECTED_ROLES[*]}" != "all" ]]; then
    for role in "${SELECTED_ROLES[@]}"; do
        if [[ ! " ${all_containers[*]} " =~ " ${role} " ]]; then
            echo "❌ Invalid role: $role"
            echo "Available roles: ${all_containers[*]}"
            exit 1
        fi
    done
fi

# Filter containers
if [[ "${SELECTED_ROLES[*]}" == "all" ]]; then
    containers=("${all_containers[@]}")
else
    containers=("${SELECTED_ROLES[@]}")
fi

# ------------------------------
# Injected Secrets from Jenkins
# ------------------------------
export TF_VAR_proxmox_token="${PROXMOX_TOKEN}"
export TF_VAR_ssh_key="$(cat ${SSH_KEY_FILE})"

# ------------------------------
# DEPLOY WITH TERRAFORM
# ------------------------------
cd "$TF_DIR"
echo "🚀 Initializing Terraform..."
terraform init

echo "📦 Applying Terraform..."
if [[ "${SELECTED_ROLES[*]}" == "all" ]]; then
    terraform apply -auto-approve
else
    targets=()
    for role in "${containers[@]}"; do
        targets+=("-target=proxmox_virtual_environment_container.${role}")
    done
    terraform apply -auto-approve "${targets[@]}"
fi

# ------------------------------
# FETCH VMIDs FROM TERRAFORM OUTPUTS
# ------------------------------
declare -A vmids

for container in "${containers[@]}"; do
    full_id=$(terraform output -raw "${container}_vmid")
    vmid=$(echo "$full_id" | cut -d'/' -f2)
    vmids[$container]=$vmid
    echo "✅ $container VMID: $vmid"
done

# ------------------------------
# WAIT FOR IPs AND INJECT SSH
# ------------------------------
declare -A ips

for container in "${containers[@]}"; do
    vmid=${vmids[$container]}
    echo "⏳ Waiting for container $container (VMID $vmid) to get an IP..."

    boot_retries=0
    while [[ "$(ssh $SSH_OPTS "$PROXMOX_SSH" "pct status $vmid" | grep -c 'status: running')" -eq 0 && $boot_retries -lt $MAX_RETRIES ]]; do
        echo -ne "🕒 Waiting for $container to boot... Attempt $((boot_retries+1)) of $MAX_RETRIES\r"
        ((boot_retries++))
        sleep $SLEEP_INTERVAL
    done

    if [[ $boot_retries -eq $MAX_RETRIES ]]; then
        echo -e "\n❌ $container (VMID $vmid) did not start in time."
        continue
    fi

    ip=""
    retries=0
    while [[ -z "$ip" && $retries -lt $MAX_RETRIES ]]; do
        echo -ne "🔄 Attempt $((retries+1)) of $MAX_RETRIES...\r"
        raw_output=$(ssh $SSH_OPTS "$PROXMOX_SSH" "pct exec $vmid -- ip a" 2>/dev/null || true)
        ip=$(echo "$raw_output" | awk '/inet / && $2 !~ /^127/ {print $2}' | cut -d/ -f1 | head -n1)
        if [[ -n "$ip" ]]; then
            echo "🌐 $container IP acquired: $ip"
            ips[$container]=$ip
            break
        fi
        ((retries++))
        sleep $SLEEP_INTERVAL
    done

    if [[ -z "${ips[$container]:-}" ]]; then
        echo "⚠️ Timeout: No IP found for $container (VMID $vmid)"
        continue
    fi

    echo "🔐 Injecting SSH key into $container..."
    ssh $SSH_OPTS "$PROXMOX_SSH" "pct exec $vmid -- mkdir -p /root/.ssh"
    ssh $SSH_OPTS "$PROXMOX_SSH" "pct exec $vmid -- bash -c \"echo '${SSH_KEY}' >> /root/.ssh/authorized_keys\""
    ssh $SSH_OPTS "$PROXMOX_SSH" "pct exec $vmid -- chmod 600 /root/.ssh/authorized_keys"
done

# ------------------------------
# GENERATE ANSIBLE INVENTORY
# ------------------------------
echo "📝 Creating Ansible inventory at $INVENTORY_FILE..."
{
    echo "[all]"
    for container in "${containers[@]}"; do
        if [[ -n "${ips[$container]:-}" ]]; then
            echo "$container ansible_host=${ips[$container]} ansible_user=root ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
        fi
    done
} > "$INVENTORY_FILE"

# ------------------------------
# RUN ANSIBLE PLAYBOOKS
# ------------------------------
cd "$ANSIBLE_DIR"
echo "🛠 Running Ansible playbooks..."

if [[ "${SELECTED_ROLES[*]}" == "all" ]]; then
    ansible-playbook -i "$INVENTORY_FILE" site.yml
else
    tags=$(IFS=','; echo "${SELECTED_ROLES[*]}")
    ansible-playbook -i "$INVENTORY_FILE" site.yml --tags "$tags"
fi

echo "✅ Ansible playbooks completed."
echo "🎉 Deployment completed successfully!"
