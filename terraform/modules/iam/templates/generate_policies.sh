#!/bin/bash
set -e

# Load environment variables
set -a
source "$(dirname "$0")/../../../../.env"
set +a
echo "DYNAMODB_TABLE_NAME is: $DYNAMODB_TABLE_NAME"

mkdir -p generated

for tpl in github_oidc_role/*.json.tpl; do
  base=$(basename "$tpl" .tpl)
  envsubst < "$tpl" > "generated/$base"
done

echo "✅ Policies generated in /generated"