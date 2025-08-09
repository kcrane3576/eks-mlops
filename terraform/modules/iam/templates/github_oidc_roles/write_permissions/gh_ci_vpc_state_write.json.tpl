{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3WriteTerraformState",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${S3_BUCKET_NAME}",
                "arn:aws:s3:::${S3_BUCKET_NAME}/*"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DynamoDBWriteTerraformStateLock",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:${REGION}:${AWS_ACCOUNT_ID}:table/${DYNAMODB_TABLE_NAME}",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "IAMManageVPCFlowLogRoles",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:TagRole",
                "iam:UntagRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/vpc-flow-log-role-*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "IAMManageVPCFlowLogPolicies",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:DeletePolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicyVersion",
                "iam:TagPolicy",
                "iam:UntagPolicy"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/vpc-flow-log-to-cloudwatch-*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "IAMAttachVPCFlowLogRolePolicies",
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/vpc-flow-log-role-*"
        },
        {
            "Sid": "IAMPassWriteRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${WRITE_ROLE_ARN}"
        }
    ]
}