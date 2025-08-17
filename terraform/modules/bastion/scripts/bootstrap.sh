#!/bin/bash
set -euo pipefail

dnf -y update
dnf -y install amazon-ssm-agent awscli jq tar gzip curl || true
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
K_VER=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases \
  | jq -r '.[0].tag_name' | sed 's/kustomize\///')
curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${K_VER}/kustomize_${K_VER}_linux_amd64.tar.gz" \
  -o /tmp/kustomize.tgz || true
tar -xzf /tmp/kustomize.tgz -C /usr/local/bin/ || true
kustomize version || true

# --- Kubeconfig ---
echo "Bootstrapping kubeconfig for ${CLUSTER} in ${REGION}..."
aws eks update-kubeconfig \
  --name "${CLUSTER}" \
  --region "${REGION}" \
  --role "arn:aws:iam::${ACCOUNT_ID}:role/${ENV}-ops-admin" || true

# Patch client-exec api version and interactiveMode
if grep -q 'client.authentication.k8s.io/v1beta1' ~/.kube/config; then
  sed -i 's#client.authentication.k8s.io/v1beta1#client.authentication.k8s.io/v1#g' ~/.kube/config
fi

if ! grep -q 'interactiveMode:' ~/.kube/config; then
  sed -i '/command: aws/a\ \ \ \ interactiveMode: Never' ~/.kube/config
fi
