{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${ACCESS_ANALYZER_GET_LIST}",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:GetAnalyzer",
                "access-analyzer:ListTagsForResource"
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
            "Sid": "${ACCESS_ANALYZER_LIST}",
            "Effect": "Allow",
            "Action": "access-analyzer:ListAnalyzers",
            "Resource": "*"
        }
    ]
}