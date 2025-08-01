import os
import subprocess
from pathlib import Path

# Load required environment variables
template_dir = os.getenv("TEMPLATE_DIR")
env_dir = os.getenv("ENV_DIR")
output_dir = os.getenv("OUTPUT_DIR")

print("🔁 Generating IAM policies per environment...")

# Clean and recreate the output directory
output_path = Path(output_dir)
if output_path.exists():
    subprocess.run(["rm", "-rf", str(output_path)], check=True)
output_path.mkdir(parents=True, exist_ok=True)

# Iterate through all *.env files (e.g., .dev.env, .prod.env)
for env_file in Path(env_dir).glob("*.env"):
    if env_file.name in [".local.env", ".github.env"]:
        continue  # Skip local and GitHub-specific env files

    # Strip the leading dot and file extension to get the environment name
    env_name = env_file.stem.lstrip(".")
    print(f"🔧 Processing environment: {env_name}")

    # Load environment variables from the .env file
    env_vars = {}
    with env_file.open() as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                key, value = line.split("=", 1)
                env_vars[key] = value

    # Explicitly export ENVIRONMENT based on file name
    env_vars["ENVIRONMENT"] = env_name

    # Process each policy type subdirectory
    for policy_type in ["read_permissions", "write_permissions", "trust_permissions"]:
        tpl_dir = Path(template_dir) / policy_type
        out_dir = output_path / env_name / policy_type
        out_dir.mkdir(parents=True, exist_ok=True)

        # Walk through each .json.tpl file recursively
        for tpl_file in tpl_dir.rglob("*.json.tpl"):
            # Compute relative subdirectory path for nested templates
            rel_dir = tpl_file.parent.relative_to(tpl_dir)
            output_target = out_dir / rel_dir / tpl_file.stem
            output_target.parent.mkdir(parents=True, exist_ok=True)

            # Read template, replace env vars, and write output
            with tpl_file.open() as f:
                content = f.read()
            for key, value in env_vars.items():
                content = content.replace(f"${{{key}}}", value)
            with output_target.open("w") as f:
                f.write(content)

            print(f"📄 Generated: {output_target}")

print(f"✅ IAM policies generated in {output_dir}/<env>/")
