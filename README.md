# eks-mlops
Simple eks / mlops setup

---

## Local Setup

### 1. Create your `.env` file
At the root of the repo, create a `.env` file with the following variables:
`AWARENESS`: single quotes (') are used in the .env file, but must be removed for secret values in github.
```env
# Github
REPO_OWNER=
REPO_NAME=
DEFAULT_BRANCH=
# AWS
AWS_ACCOUNT_ID=
ENVIRONMENT=
REGION=
TAGS=
# IAM
ROLE_TARGET=
ROLE_PURPOSE=
READ_ROLE_ARN=
WRITE_ROLE_ARN=
## IAM Policies
### IAM Management
IAM_MANAGEMENT=
### Terraform
S3_BUCKET_NAME=
S3_BUCKET_KEY=
DYNAMODB_TABLE_NAME=
S3=
DYNAMODB=
### VPC
VPC_NAME=
CIDR_BLOCK=
AZS=
PRIVATE_SUBNETS=
PUBLIC_SUBNETS=
ENABLE_VPC_FLOW_LOGS=
VPC_DESCRIBE_DISASSOCIATE=
VPC_CREATE_STRICT=
VPC_CREATE_RELAXED=
VPC_CREATE_RELAXED_NAT_GATEWAY=
VPC_MODIFY_DELETE=
VPC_REPLACE_NACL_ASSOCIATION=
VPC_DISASSOCIATE_ROUTE_TABLE=
VPC_REVOKE_SECURITY_GROUP_RULE=
VPC_CREATE_TAG=
VPC_CREATE_TAG_EIP=
VPC_DELETE_TAG=
VPC_CHANGE_TAG=
### Cloudwatch
CLOUDWATCH_LOGS_DESCRIBE=
CLOUDWATCH_LOGS_CREATE_PUT_TAG=
CLOUDWATCH_LOGS_LIST=
CLOUDWATCH_LOGS_CREATE_FLOW_LOG=
CLOUDWATCH_LOGS_DELETE_FLOW_LOG=
CLOUDWATCH_LOGS_PASS_ROLE_FOR_FLOW_LOG=
### EKS
CLUSTER_NAME=
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
- Configure a repository Github variable for `REPO_CAN_RUN_CI` to restrict access to who can run your Github actions.
---

## Remote State

Terraform uses an S3 backend with DynamoDB state locking. You must configure the values in the `terraform init` step of GitHub Actions based on the `env` values above.

---

## GitHub Actions Auth

This repo uses [OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to securely assume AWS roles without storing AWS credentials in GitHub.

---
