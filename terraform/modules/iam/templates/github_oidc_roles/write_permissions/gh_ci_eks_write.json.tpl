{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${IAM_GET_SCOPE_ROLES_NODE_GROUP}",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:TagRole",
                "iam:PassRole",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": "arn:aws:iam::728852640881:role/*"
        },
        {
            "Sid": "${IAM_GET_SCOPE_ROLES_WRITE}",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${WRITE_ROLE_ARN}"
        },
        {
            "Sid": "GithubCIEKSCloudwatchLogsCreateAccess",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/eks/*:log-stream:*"
        },
        {
            "Sid": "GithubCIEKSSecurityGroupsAndTags",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:DeleteTags"
            ],
            "Resource": "*"
        }
    ]
}