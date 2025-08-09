{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessAnalyzerCreateAnalyzerEnforceTags",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:CreateAnalyzer",
                "access-analyzer:TagResource"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo"
                    ]
                }
            }
        },
        {
            "Sid": "AccessAnalyzerDeleteAnalyzerByEnv",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:DeleteAnalyzer"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo"
                    ]
                }
            }
        },
        {
            "Sid": "IAMCreateSLRForAccessAnalyzer",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/access-analyzer.amazonaws.com/AWSServiceRoleForAccessAnalyzer",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "access-analyzer.amazonaws.com"
                }
            }
        }
    ]
}