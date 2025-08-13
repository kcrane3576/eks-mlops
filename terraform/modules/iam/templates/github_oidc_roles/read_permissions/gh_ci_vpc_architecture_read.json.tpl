{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2DescribeVPCTags",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeVpcEndpoints"
            ],
            "Resource": "*"
        }
    ]
}