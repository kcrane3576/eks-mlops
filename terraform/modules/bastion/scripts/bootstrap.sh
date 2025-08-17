#!/bin/bash
set -euo pipefail

dnf -y update
dnf -y install amazon-ssm-agent awscli jq tar gzip || true
systemctl enable --now amazon-ssm-agent

mkdir -p /tmp/k8s

echo "Finding latest kubectl for ${KUBERNETES_MINOR_VERSION}..."
LATEST_PATH=$(aws --region ${EKS_ARTIFACTS_REGION} s3 ls s3://amazon-eks/ --recursive \
  | grep "bin/linux/amd64/kubectl$" \
  | grep "^.*${KUBERNETES_MINOR_VERSION}\\." \
  | sort \
  | tail -n 1 \
  | awk '{print $4}')

if [ -z "$LATEST_PATH" ]; then
  echo "ERROR: Could not find kubectl for ${KUBERNETES_MINOR_VERSION} in S3 bucket amazon-eks"
  exit 1
fi

echo "Downloading kubectl from s3://amazon-eks/$LATEST_PATH"
aws --region ${EKS_ARTIFACTS_REGION} s3 cp "s3://amazon-eks/$LATEST_PATH" /tmp/k8s/kubectl
install -m 0755 /tmp/k8s/kubectl /usr/local/bin/kubectl
kubectl version --client || true

# --- Helm ---
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
helm version || true

# --- Kustomize ---
K_TAG=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases \
  | jq -r '.[0].tag_name')                 # e.g. "kustomize/v5.4.3"
K_FILE_VER="${K_TAG#kustomize/}"           # e.g. "v5.4.3"
curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/$${K_TAG}/kustomize_$${K_FILE_VER}_linux_amd64.tar.gz" \
  -o /tmp/kustomize.tgz || true
tar -xzf /tmp/kustomize.tgz -C /usr/local/bin/ || true
kustomize version || true

# --- Kubeconfig (defer to first login) ---
echo "Installing first-login kubeconfig hook..."

# Writes a helper that will create kubeconfig for the *current* user on first login
# Values below are baked in at template time
cat >/usr/local/bin/eks-kubeconfig-onlogin.sh <<EOF
#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION}"
CLUSTER="${CLUSTER}"
ENV="${ENV}"
ACCOUNT_ID="${ACCOUNT_ID}"

KUBEDIR="\${HOME}/.kube"
KUBECONFIG_PATH="\${KUBEDIR}/config"

# Only run once per user
if [ ! -f "\${KUBECONFIG_PATH}" ]; then
  mkdir -p "\${KUBEDIR}"

  aws eks update-kubeconfig \
    --name "\${CLUSTER}" \
    --region "\${REGION}" \
    --role "arn:aws:iam::\${ACCOUNT_ID}:role/\${ENV}-ops-admin"

  # Normalize exec API to v1
  if grep -q 'client.authentication.k8s.io/v1beta1' "\${KUBECONFIG_PATH}"; then
    sed -i 's#client.authentication.k8s.io/v1beta1#client.authentication.k8s.io/v1#g' "\${KUBECONFIG_PATH}"
  fi

  # Insert 'interactiveMode: Never' immediately under 'command: aws' if missing
  awk '
    {
      print
      if (!added && \$0 ~ /^[[:space:]]*command:[[:space:]]aws$/) {
        match(\$0, /^[[:space:]]*/); pad=substr(\$0,1,RLENGTH);
        print pad "interactiveMode: Never"
        added=1
      }
    }
  ' "\${KUBECONFIG_PATH}" > "\${KUBECONFIG_PATH}.new" && mv "\${KUBECONFIG_PATH}.new" "\${KUBECONFIG_PATH}"
fi
EOF
chmod +x /usr/local/bin/eks-kubeconfig-onlogin.sh

# Profile hook: run the helper on each login if kubeconfig is missing
cat >/etc/profile.d/10-eks-kubeconfig.sh <<'EOF'
# Create EKS kubeconfig on first login (SSM or SSH) if missing
if command -v aws >/dev/null 2>&1; then
  if [ ! -f "${HOME}/.kube/config" ]; then
    /usr/local/bin/eks-kubeconfig-onlogin.sh || true
  fi
fi
EOF
chmod 644 /etc/profile.d/10-eks-kubeconfig.sh

echo "Kubeconfig will be generated on first login for the current user."