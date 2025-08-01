{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${VPC_DESCRIBE_DISASSOCIATE}",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeAddresses",
                "ec2:DescribeAddressesAttribute",
                "ec2:DescribeFlowLogs",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DisassociateAddress",
                "ec2:DescribeNetworkAcls"
            ],
            "Resource": "*"
        },
        {
            "Sid": "${VPC_CREATE_STRICT}",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVpc",
                "ec2:CreateInternetGateway",
                "ec2:AllocateAddress",
                "ec2:CreateFlowLogs"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo",
                        "kubernetes.io/cluster/${CLUSTER_NAME}",
                        "kubernetes.io/role/elb",
                        "kubernetes.io/role/internal-elb"
                    ]
                }
            }
        },
        {
            "Sid": "${VPC_CREATE_RELAXED}",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSubnet",
                "ec2:CreateRouteTable",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAclEntry"
            ],
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${VPC_CREATE_RELAXED_NAT_GATEWAY}",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNatGateway"
            ],
            "Resource": "*"
        },
        {
            "Sid": "${VPC_MODIFY_DELETE}",
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVpc",
                "ec2:DeleteTags",
                "ec2:ModifyVpcAttribute",
                "ec2:DeleteSubnet",
                "ec2:DeleteRouteTable",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:AssociateRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:DeleteInternetGateway",
                "ec2:AttachInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:ReleaseAddress",
                "ec2:AssociateAddress",
                "ec2:DeleteFlowLogs",
                "ec2:DeleteNatGateway",
                "ec2:DeleteNetworkAcl",
                "ec2:DeleteNetworkAclEntry",
                "ec2:ReplaceNetworkAclEntry"
            ],
            "Resource": [
                "arn:aws:ec2:${REGION}:*:vpc/*",
                "arn:aws:ec2:${REGION}:*:subnet/*",
                "arn:aws:ec2:${REGION}:*:route-table/*",
                "arn:aws:ec2:${REGION}:*:internet-gateway/*",
                "arn:aws:ec2:${REGION}:*:natgateway/*",
                "arn:aws:ec2:${REGION}:*:elastic-ip/*",
                "arn:aws:ec2:${REGION}:*:network-acl/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${VPC_REPLACE_NACL_ASSOCIATION}",
            "Effect": "Allow",
            "Action": "ec2:ReplaceNetworkAclAssociation",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${VPC_DISASSOCIATE_ROUTE_TABLE}",
            "Effect": "Allow",
            "Action": "ec2:DisassociateRouteTable",
            "Resource": "*"
        },
        {
            "Sid": "${VPC_REVOKE_SECURITY_GROUP_RULE}",
            "Effect": "Allow",
            "Action": [
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": [
                "arn:aws:ec2:${REGION}:*:security-group/*"
            ],
            "Condition": {
                "StringEqualsIfExists": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${VPC_CREATE_TAG}",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": [
                "arn:aws:ec2:${REGION}:*:vpc/*",
                "arn:aws:ec2:${REGION}:*:subnet/*",
                "arn:aws:ec2:${REGION}:*:network-acl/*",
                "arn:aws:ec2:${REGION}:*:route-table/*",
                "arn:aws:ec2:${REGION}:*:internet-gateway/*",
                "arn:aws:ec2:${REGION}:*:security-group/*",
                "arn:aws:ec2:${REGION}:*:natgateway/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                },
                "ForAnyValue:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo",
                        "kubernetes.io/cluster/${CLUSTER_NAME}",
                        "kubernetes.io/role/elb",
                        "kubernetes.io/role/internal-elb"
                    ]
                }
            }
        },
                {
            "Sid": "${VPC_CREATE_TAG_EIP}",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo",
                        "kubernetes.io/cluster/${CLUSTER_NAME}",
                        "kubernetes.io/role/elb",
                        "kubernetes.io/role/internal-elb"
                    ]
                }
            }
        },
        {
            "Sid": "${VPC_DELETE_TAG}",
            "Effect": "Deny",
            "Action": "ec2:DeleteTags",
            "Resource": [
                "arn:aws:ec2:${REGION}:*:vpc/*",
                "arn:aws:ec2:${REGION}:*:subnet/*",
                "arn:aws:ec2:${REGION}:*:network-acl/*",
                "arn:aws:ec2:${REGION}:*:route-table/*",
                "arn:aws:ec2:${REGION}:*:internet-gateway/*",
                "arn:aws:ec2:${REGION}:*:security-group/*",
                "arn:aws:ec2:${REGION}:*:natgateway/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                },
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": ["Environment", "Repo"]
                }
            }
        },
        {
            "Sid": "${VPC_CHANGE_TAG}",
            "Effect": "Deny",
            "Action": "ec2:CreateTags",
            "Resource": [
                "arn:aws:ec2:${REGION}:*:vpc/*",
                "arn:aws:ec2:${REGION}:*:subnet/*",
                "arn:aws:ec2:${REGION}:*:network-acl/*",
                "arn:aws:ec2:${REGION}:*:route-table/*",
                "arn:aws:ec2:${REGION}:*:internet-gateway/*",
                "arn:aws:ec2:${REGION}:*:security-group/*",
                "arn:aws:ec2:${REGION}:*:natgateway/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                },
                "StringNotEqualsIfExists": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                },
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": ["Environment"]
                }
            }
        }
    ]
}