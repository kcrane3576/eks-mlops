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
command -v curl >/dev/null 2>&1 || { echo "curl not found"; exit 1; }
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
helm version || true

# --- Kustomize ---
K_TAG=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | jq -r '.[0].tag_name')
K_FILE_VER="\${K_TAG#kustomize/}"   # "kustomize/vX.Y.Z" -> "vX.Y.Z"
curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/$K_TAG/kustomize_$K_FILE_VER_linux_amd64.tar.gz" -o /tmp/kustomize.tgz || true
if [ -s /tmp/kustomize.tgz ]; then
  tar -xzf /tmp/kustomize.tgz -C /tmp/ || true
  install -m 0755 /tmp/kustomize /usr/local/bin/kustomize || true
  kustomize version || true
else
  echo "WARNING: Kustomize tarball not downloaded; skipping install."
fi

# --- Kubeconfig (root) ---
# Requires: bastion instance role has eks:DescribeCluster on the cluster ARN.
echo "Bootstrapping kubeconfig for ${CLUSTER} in ${REGION} (root)..."
aws eks update-kubeconfig \
  --name "${CLUSTER}" \
  --region "${REGION}" \
  --role "arn:aws:iam::${ACCOUNT_ID}:role/${ENV}-ops-admin" || true

# Normalize client-exec API and ensure interactiveMode
if [ -f ~/.kube/config ]; then
  sed -i 's#client.authentication.k8s.io/v1beta1#client.authentication.k8s.io/v1#g' ~/.kube/config || true
  awk '
    {
      print
      if (!added && $0 ~ /^[[:space:]]*command:[[:space:]]aws$/) {
        match($0, /^[[:space:]]*/); pad=substr($0,1,RLENGTH);
        print pad "interactiveMode: Never"
        added=1
      }
    }
  ' ~/.kube/config > ~/.kube/config.new && mv ~/.kube/config.new ~/.kube/config || true
fi
