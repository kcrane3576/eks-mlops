{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IAMGetRoleReadRole",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${READ_ROLE_ARN}"
        },
        {
            "Sid": "IAMReadNodeGroupRoles",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies"
            ],
            "Resource": "arn:aws:iam::728852640881:role/*"
        },
        {
            "Sid": "IAMGetPolicyInAccount",
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicy"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/*"
        },
        {
            "Sid": "SSMGetEksOptimizedAMIParam",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*::parameter/aws/service/eks/optimized-ami*"
        },
        {
            "Sid": "EC2DescribeNetworkForEKS",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeAddresses",
                "ec2:DescribeAddressesAttribute",
                "ec2:DescribeFlowLogs",
                "ec2:DescribeNatGateways",
                "ec2:DescribeInstances",
                "ec2:DescribeLaunchTemplates"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LogsDescribeLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LogsListTagsForEKSAndVPCLogs",
            "Effect": "Allow",
            "Action": [
                "logs:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/vpc-flow-log/*",
                "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/eks/*"
            ]
        },
        {
            "Sid": "EKSDescribeCluster",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:DescribeAccessEntry",
                "eks:DescribeAddonVersions",
                "eks:DescribeAddon"
            ],
            "Resource": "*"
        },
        {
            "Sid": "KMSReadKeyMetadata",
            "Effect": "Allow",
            "Action": [
                "kms:ListAliases",
                "kms:DescribeKey",
                "kms:GetKeyPolicy",
                "kms:GetKeyRotationStatus",
                "kms:ListResourceTags"
            ],
            "Resource": "*"
        }
    ]
}