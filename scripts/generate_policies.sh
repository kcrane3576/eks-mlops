#!/bin/bash
set -euo pipefail

echo "🔁 Generating IAM policies per environment..."

TEMPLATE_DIR="terraform/modules/iam/templates/github_oidc_roles"
ENV_DIR="env"
OUTPUT_DIR="terraform/modules/iam/templates/generated"

# Clean old output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Enable dotglob so hidden files (like .dev.env) are matched
shopt -s dotglob

# Iterate over each .env file (e.g., .dev.env, .prod.env)
for env_file in "$ENV_DIR"/*.env; do
  ENV_NAME=$(basename "$env_file" .env | sed 's/^\.//')

  echo "🔧 Processing environment: $ENV_NAME"

  # Load environment variables
  set -a
  source "$env_file"
  set +a

  for policy_type in read_permissions write_permissions trust_permissions; do
    TEMPLATE_SUBDIR="$TEMPLATE_DIR/$policy_type"
    OUTPUT_SUBDIR="$OUTPUT_DIR/$ENV_NAME/$policy_type"

    mkdir -p "$OUTPUT_SUBDIR"

    find "$TEMPLATE_SUBDIR" -type f -name '*.json.tpl' | while read -r tpl; do
      relative_dir=$(dirname "$tpl" | sed "s|^$TEMPLATE_SUBDIR/?||")
      base=$(basename "$tpl" .tpl)

      mkdir -p "$OUTPUT_SUBDIR/$relative_dir"
      envsubst < "$tpl" > "$OUTPUT_SUBDIR/$relative_dir/$base"
      echo "📄 Generated: $OUTPUT_SUBDIR/$relative_dir/$base"
    done
  done
done

echo "✅ IAM policies generated in $OUTPUT_DIR/<env>/"
