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
            "Resource": "*"
        },
        {
            "Sid": "${ACCESS_ANALYZER_LIST}",
            "Effect": "Allow",
            "Action": "access-analyzer:ListAnalyzers",
            "Resource": "*"
        }
    ]
}