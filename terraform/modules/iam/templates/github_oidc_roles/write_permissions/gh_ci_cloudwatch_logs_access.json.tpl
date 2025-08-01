{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${CLOUDWATCH_LOGS_DESCRIBE}",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_PUT_TAG}",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:TagResource",
                "logs:UntagResource",
                "logs:DeleteLogGroup"
            ],
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/vpc-flow-log/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_CREATE}",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream"
            ],
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/vpc-flow-log/*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_LIST}",
            "Effect": "Allow",
            "Action": [
                "logs:ListTagsForResource"
            ],
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/vpc-flow-log/*"
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_CREATE_FLOW_LOG}",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateFlowLogs"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_DELETE_FLOW_LOG}",
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteFlowLogs"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "${CLOUDWATCH_LOGS_PASS_ROLE_FOR_FLOW_LOG}",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/vpc-flow-log-role-*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "vpc-flow-logs.amazonaws.com"
                }
            }
        }
    ]
}