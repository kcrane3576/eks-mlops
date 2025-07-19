{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "$CLOUDWATCH_LOGS_ACCESS_SID",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:$REGION:$AWS_ACCOUNT_ID:log-group:/aws/vpc-flow-log/*"
    }
  ]
}