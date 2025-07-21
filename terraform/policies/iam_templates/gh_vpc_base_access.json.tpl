{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$VPC_BASE_DESCRIBE_DISASSOCIATE_SID",
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
                "ec2:DisassociateAddress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "$VPC_BASE_CREATE_SID",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVpc",
                "ec2:CreateSubnet",
                "ec2:CreateRouteTable",
                "ec2:CreateInternetGateway",
                "ec2:AllocateAddress",
                "ec2:CreateFlowLogs",
                "ec2:CreateNatGateway"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "$ENVIRONMENT"
                },
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": ["Environment"]
                }
            }
        },
        {
            "Sid": "$VPC_BASE_MODIFY_DELETE_SID",
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVpc",
                "ec2:CreateTags",
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
                "ec2:RevokeSecurityGroupEgress",
                "ec2:ReleaseAddress",
                "ec2:AssociateAddress",
                "ec2:DeleteFlowLogs",
                "ec2:DeleteNatGateway",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                }
            }
        },
        {
            "Sid": "$VPC_BASE_DENY_DELETE_TAG_SID",
            "Effect": "Deny",
            "Action": "ec2:DeleteTags",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                },
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": ["Environment"]
                }
            }
        },
        {
            "Sid": "$VPC_BASE_DENY_CHANGE_TAG_SID",
            "Effect": "Deny",
            "Action": "ec2:CreateTags",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                },
                "StringNotEqualsIfExists": {
                    "aws:RequestTag/Environment": "$ENVIRONMENT"
                },
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": ["Environment"]
                }
            }
        }
    ]
}