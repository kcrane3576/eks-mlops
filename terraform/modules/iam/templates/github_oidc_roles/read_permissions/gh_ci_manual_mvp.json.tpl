{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ReadTerraformState",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${STATE_BUCKET_NAME}",
                "arn:aws:s3:::${STATE_BUCKET_NAME}/*"
            ]
        },
        {
            "Sid": "DynamoDBReadTerraformStateLock",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:DescribeTable"
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