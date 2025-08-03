{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${IAM_READ_SCOPE_ROLES}",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": [
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/vpc-flow-log-role-*",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${READ_ROLE_ARN}*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${IAM_READ_SCOPE_POLICIES}",
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/vpc-flow-log-to-cloudwatch-*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        }
    ]
}