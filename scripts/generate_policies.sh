#!/bin/bash
set -e

# Load environment variables from repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
source "$REPO_ROOT/.env"


# Paths
TEMPLATE_ROOT="$REPO_ROOT/terraform/modules/iam/templates/github_oidc_roles"
GENERATED_ROOT="$REPO_ROOT/terraform/modules/iam/templates/generated"

mkdir -p "$GENERATED_ROOT"

find "$TEMPLATE_ROOT" -type f -name '*.json.tpl' | while read -r tpl; do
  relative_dir=$(dirname "$tpl" | sed "s|$TEMPLATE_ROOT/||")
  base=$(basename "$tpl" .tpl)
  target_dir="$GENERATED_ROOT/$relative_dir"
  mkdir -p "$target_dir"
  envsubst < "$tpl" > "$target_dir/$base"
done

echo "✅ Policies generated in $GENERATED_ROOT"