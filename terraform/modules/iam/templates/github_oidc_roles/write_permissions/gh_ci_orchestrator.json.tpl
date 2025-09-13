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
                "arn:aws:s3:::dev-eks-mlops-tfstate",
                "arn:aws:s3:::dev-eks-mlops-tfstate/*"
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
            "Resource": "arn:aws:dynamodb:us-east-1:${AWS_ACCOUNT_ID}:table/dev-eks-mlops-tfstate-lock",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "dev"
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
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/GithubCIReadRoleDev",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/GithubCIWriteRoleDev"
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
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/GithubCIWriteRoleDev",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "ci-orchestrator-dev"
                }
            }
        }
    ]
}