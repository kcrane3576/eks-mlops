{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$CLOUDWATCH_LOGS_DESCRIBE_SID",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        },
        {
            "Sid": "$CLOUDWATCH_LOGS_CREATE_PUT_TAG_SID",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:TagResource",
                "logs:UntagResource",
                "logs:ListTagsForResource",
                "logs:DeleteLogGroup"
            ],
            "Resource": "arn:aws:logs:$REGION:$AWS_ACCOUNT_ID:log-group:/aws/vpc-flow-log/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                }
            }
        }
    ]
}