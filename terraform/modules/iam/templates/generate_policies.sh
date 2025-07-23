#!/bin/bash
set -e

# Load environment variables
set -a
source "$(dirname "$0")/../../../../.env"
set +a
echo "DYNAMODB_TABLE_NAME is: $DYNAMODB_TABLE_NAME"

mkdir -p generated

find github_oidc_roles -type f -name '*.json.tpl' | while read -r tpl; do
  relative_dir=$(dirname "$tpl" | sed 's/^github_oidc_roles\///')
  base=$(basename "$tpl" .tpl)
  mkdir -p "generated/$relative_dir"
  envsubst < "$tpl" > "generated/$relative_dir/$base"
done

echo "✅ Policies generated in /generated"