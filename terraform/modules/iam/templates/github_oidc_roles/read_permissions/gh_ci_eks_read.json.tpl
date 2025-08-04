{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${IAM_GET_SCOPE_ROLES_READ}",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${READ_ROLE_ARN}"
        },
        {
            "Sid": "${EKS_SSM_READ_AMI}",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*::parameter/aws/service/eks/optimized-ami*"
        }
    ]
}