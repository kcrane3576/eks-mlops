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
DYNAMODB_TABLE_NAME=

# Policy SIDs
TF_S3_SID=
TF_DYNAMODB_SID=
VPC_DESCRIBE_DISASSOCIATE_SID=
VPC_CREATE_STRICT_SID=
VPC_CREATE_RELAXED_SID=
VPC_CREATE_RELAXED_NAT_GATEWAY_SID=
VPC_MODIFY_DELETE_SID=
VPC_REPLACE_NACL_ASSOCIATION_SID=
VPC_DISASSOCIATE_ROUTE_TABLE_ALLOW=
VPC_DENY_UNTAGGED_NACL_NAT_SID=
VPC_ALLOW_SECURITY_GROUP_RULE_CHANGE_SID=
VPC_DENY_DELETE_TAG_SID=
VPC_CREATE_TAG_SID=
VPC_CREATE_TAG_EIP_SID=
VPC_DENY_CHANGE_TAG_SID=
IAM_MANAGEMENT_SID=
CLOUDWATCH_LOGS_DESCRIBE_SID=
CLOUDWATCH_LOGS_CREATE_PUT_TAG_SID=
CLOUDWATCH_LOGS_LIST_RESOURCE_SID=
CLOUDWATCH_LOGS_CREATE_FLOW_LOG_SID=
CLOUDWATCH_LOGS_DELETE_FLOW_LOG_SID=
CLOUDWATCH_LOGS_PASS_ROLE_FOR_FLOW_LOG_SID=
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