{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ReadWriteTerraformState",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${STATE_BUCKET_NAME}",
                "arn:aws:s3:::${STATE_BUCKET_NAME}/*"
            ]
        },
        {
            "Sid": "DynamoDBReadWriteTerraformStateLock",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:DescribeTable",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:${REGION}:${AWS_ACCOUNT_ID}:table/${STATE_LOCK_TABLE_NAME}",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        }
    ]
}