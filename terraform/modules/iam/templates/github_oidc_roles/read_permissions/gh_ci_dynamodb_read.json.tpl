{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$DYNAMODB_READ",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:DescribeTable"
            ],
            "Resource": "arn:aws:dynamodb:$REGION:$AWS_ACCOUNT_ID:table/$DYNAMODB_TABLE_NAME",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "$ENVIRONMENT"
                }
            }
        }
    ]
}