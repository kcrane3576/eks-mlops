{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ReadTerraformState",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${S3_BUCKET_NAME}",
                "arn:aws:s3:::${S3_BUCKET_NAME}/*"
            ]
        },
        {
            "Sid": "DynamoDBReadTerraformStateLock",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:DescribeTable"
            ],
            "Resource": "arn:aws:dynamodb:${REGION}:${AWS_ACCOUNT_ID}:table/${DYNAMODB_TABLE_NAME}",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "IAMReadVPCFlowLogRoles",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/vpc-flow-log-role-*"
        },
        {
            "Sid": "IAMReadVPCFlowLogPolicies",
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/vpc-flow-log-to-cloudwatch-*"
        }
    ]
}