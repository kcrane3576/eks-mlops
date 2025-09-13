{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateS3ReadWrite",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${STATE_BUCKET_NAME}",
                "arn:aws:s3:::${STATE_BUCKET_NAME}/*"
            ]
        },
        {
            "Sid": "TerraformLockDynamoDBReadWrite",
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:${REGION}:${AWS_ACCOUNT_ID}:table/${STATE_LOCK_TABLE_NAME}",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "IamReadOnlyForPlans",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions"
            ],
            "Resource": [
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/*",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/*"
            ]
        },
        {
            "Sid": "CreateCiPoliciesWithTagsOnly",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:TagPolicy",
                "iam:UntagPolicy"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/owner": "platform",
                    "aws:RequestTag/purpose": "ci"
                }
            }
        },
        {
            "Sid": "ManageCiPoliciesWithResourceTags",
            "Effect": "Allow",
            "Action": [
                "iam:DeletePolicy",
                "iam:DeletePolicyVersion",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/platform/ci/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/owner": "platform",
                    "aws:ResourceTag/purpose": "ci"
                }
            }
        },
        {
            "Sid": "AttachDetachCiPoliciesToReadAndWriteOnly",
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies"
            ],
            "Resource": [
                "${READ_ROLE_ARN}",
                "${WRITE_ROLE_ARN}"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PolicyARN": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/platform/ci/*"
                }
            }
        },
        {
            "Sid": "AssumeCiWriteRole",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${WRITE_ROLE_NAME}"
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "ci-orchestrator-dev"
                }
            }
        }
    ]
}