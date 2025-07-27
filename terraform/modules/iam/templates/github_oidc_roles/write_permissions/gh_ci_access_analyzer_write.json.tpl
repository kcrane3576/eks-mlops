{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "$ACCESS_ANALYZER_MANAGEMENT",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:CreateAnalyzer",
                "access-analyzer:TagResource",
                "access-analyzer:GetAnalyzer",
                "access-analyzer:DeleteAnalyzer",
                "access-analyzer:ListAnalyzers",
                "access-analyzer:ListTagsForResource"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "$ENVIRONMENT"
                },
                "ForAllValues:StringLike": {
                    "aws:TagKeys": [
                        "Environment",
                        "Name",
                        "Repo"
                    ]
                }
            }
        }
    ]
}