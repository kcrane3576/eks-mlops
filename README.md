# eks-mlops
Simple eks / mlops setup

---

## Local Setup

### 1. Create your `.env` file
At the root of the repo, create a `.env` file with the following variables:
`AWARENESS`: single quotes (') are used in the .env file, but must be removed for secret values in github.
```env
AWS_ACCOUNT_ID=
ROLE_TO_ASSUME=
ENVIRONMENT=
REGION=
VPC_NAME=
CIDR_BLOCK=
AZS=
PRIVATE_SUBNETS=
PUBLIC_SUBNETS=
ENABLE_VPC_FLOW_LOGS=
TAGS=
CLUSTER_NAME=
S3_BUCKET_NAME=
S3_BUCKET_KEY=
S3_ACCESS_SID=
DYNAMODB_TABLE_NAME=
DYNAMODB_ACCESS_SID=
VPC_ACCESS_SID=
```
This file is ignored via `.gitignore`.

### 2. Format code
```bash
make format
```

### 3. Static analysis
```bash
make scan
```

---

## Git Tips
```shell
    git checkout main && \
    git pull origin main && \
    git checkout -b init && \
    git merge main
```

---

## Remote State

Terraform uses an S3 backend with DynamoDB state locking. You must configure the values in the `terraform init` step of GitHub Actions based on the `env` values above.

---

## GitHub Actions Auth

This repo uses [OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to securely assume AWS roles without storing AWS credentials in GitHub.

---
