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
        },
        {
            "Sid": "${VPC_DESCRIBE_DISASSOCIATE_READ}",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkAcls"
            ],
            "Resource": "*"
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_DESCRIBE_READ}",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        }
    ]
}