# eks-mlops-blueprint
Minimal 3-layer Terraform layout with GitHub Actions CI.

---

## Local Setup

### 1. Create your `.env` file
At the root of the repo, create a `.env` file with the following variables:
```env
AWS_ACCOUNT_ID=your_aws_account_id
AWS_REGION=your_aws_region
S3_BUCKET_NAME=your_s3_bucket_name
S3_BUCKET_KEY=your_s3_bucket_key
S3_ACCESS_SID=your_s3_access_sid
DYNAMODB_TABLE_NAME=your_dynamodb_table_name
DYNAMODB_ACCESS_SID=your_dynamodb_access_sid
VPC_ACCESS_SID=your_vpc_access_sid
```
This file is ignored via `.gitignore`.

### 2. Format code
```bash
make format
```

> Note: Only `format` is supported locally to avoid state conflicts. Full init/plan/apply is handled via GitHub Actions.

---

## CI/CD and Deployment Flow

1. Start by following the manual setup steps in [docs/01-bootstrap.md](./docs/01-bootstrap.md)
2. Configure GitHub Actions as shown in [docs/02-ci-setup.md](./docs/02-ci-setup.md)
3. Use PRs to trigger Terraform plans. Merges to `main` trigger `apply`.

---

## Git Tips
```shell
    git checkout main && \
    git pull origin main && \
    git checkout -b init && \
    git merge main
```
---

## Structure

- `terraform/composition`: Top-level env-specific orchestration
- `terraform/infrastructure_modules`: Composable units like networking
- `terraform/policies/iam_templates`: IAM policy definition templates for CI access
- `Makefile`: Format helper (Docker-based)
- `.github/workflows`: GitHub Actions CI pipelines

---

## Remote State

Terraform uses an S3 backend with DynamoDB state locking. You must configure the values in the `terraform init` step of GitHub Actions. See [01-bootstrap.md](./docs/01-bootstrap.md).

---

## GitHub Actions Auth

This repo uses [OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to securely assume AWS roles without storing AWS credentials in GitHub.

---