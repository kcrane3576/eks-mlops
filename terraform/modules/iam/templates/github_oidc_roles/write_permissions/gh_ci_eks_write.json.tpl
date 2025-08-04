{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${IAM_GET_SCOPE_ROLES_NODE_GROUP}",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:GetRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:TagRole",
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::728852640881:role/default-eks-node-group-*"
        },
        {
            "Sid": "${IAM_GET_SCOPE_ROLES_WRITE}",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${WRITE_ROLE_ARN}"
        }
    ]
}