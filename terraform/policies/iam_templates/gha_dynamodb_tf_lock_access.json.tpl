{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$DYNAMODB_ACCESS_SID",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeTable"
            ],
            "Resource": "arn:aws:dynamodb:$REGION:$AWS_ACCOUNT_ID:table/$DYNAMODB_TABLE_NAME"
        }
    ]
}