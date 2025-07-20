{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$VPC_NACL_DESCRIBE_SID",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeNetworkAcls"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                }
            }
        },
        {
            "Sid": "$VPC_NACL_MODIFY_SID",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkAcl",
                "ec2:DeleteNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:DeleteNetworkAclEntry",
                "ec2:ReplaceNetworkAclEntry",
                "ec2:ReplaceNetworkAclAssociation",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:*:vpc/*",
                "arn:aws:ec2:us-east-1:*:network-acl/*",
                "arn:aws:ec2:us-east-1:*:subnet/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                }
            }
        }
    ]
}