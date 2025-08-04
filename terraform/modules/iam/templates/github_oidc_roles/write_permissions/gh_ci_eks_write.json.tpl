{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${IAM_GET_SCOPE_ROLES}",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${WRITE_ROLE_ARN}"
        }
    ]
}