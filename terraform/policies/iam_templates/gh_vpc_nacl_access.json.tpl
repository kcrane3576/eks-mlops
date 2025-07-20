{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$VPC_NACL_SID",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkAcl",
                "ec2:DescribeNetworkAcls",
                "ec2:DeleteNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:DeleteNetworkAclEntry",
                "ec2:ReplaceNetworkAclEntry",
                "ec2:ReplaceNetworkAclAssociation"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:*:vpc/$VPC_NAME",
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