{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2DescribeVPCTags",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribePrefixLists",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
}