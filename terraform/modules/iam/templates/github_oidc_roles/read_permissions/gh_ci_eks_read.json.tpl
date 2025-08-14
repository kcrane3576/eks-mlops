{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IAMGetRoleReadRole",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "${READ_ROLE_ARN}"
        },
        {
            "Sid": "IAMGetClusterNodeGroupAndSLRRoles",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": [
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/default-eks-node-group-*",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER_NAME}-*",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${BASTION_NAME}-*",
                "arn:aws:iam::${AWS_ACCOUNT_ID}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
            ]
        },
        {
            "Sid": "IAMListPoliciesForRoles",
            "Effect": "Allow",
            "Action": [
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMGetPolicyInAccount",
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicy",
                "iam:GetPolicyVersion"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/*"
        },
        {
            "Sid": "IAMInstanceProfileForBastion",
            "Effect": "Allow",
            "Action": [
                "iam:GetInstanceProfile"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:instance-profile/*"
        },
        {
            "Sid": "SSMGetEksPublicAMIs",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath",
                "ssm:DescribeParameters"
            ],
            "Resource": [
                "arn:aws:ssm:${REGION}:*:parameter/aws/service/eks/*",
                "arn:aws:ssm:${REGION}:*:parameter/aws/service/al2023/*"
            ]
        },
        {
            "Sid": "EC2DescribeImagesForAMIResolution",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages"
            ],
            "Resource": "*"
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
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeLaunchTemplateVersions"
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
                "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/eks/${CLUSTER_NAME}/cluster"
            ]
        },
        {
            "Sid": "EKSDescribeClusterScoped",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:DescribeAccessEntry",
                "eks:DescribeAddon",
                "eks:DescribeNodegroup",
                "eks:ListAssociatedAccessPolicies"
            ],
            "Resource": [
                "arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}",
                "arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:nodegroup/${CLUSTER_NAME}/*",
                "arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:addon/${CLUSTER_NAME}/*",
                "arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:access-entry/${CLUSTER_NAME}/role/${AWS_ACCOUNT_ID}/*"

            ]
        },
        {
            "Sid": "EKSDescribeAddonVersionsAny",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeAddonVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMGetOIDCProviders",
            "Effect": "Allow",
            "Action": [
                "iam:GetOpenIDConnectProvider"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION}.amazonaws.com/id/*"
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