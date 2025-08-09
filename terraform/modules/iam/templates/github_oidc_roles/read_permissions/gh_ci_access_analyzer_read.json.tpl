{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessAnalyzerReadAnalyzer",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:GetAnalyzer",
                "access-analyzer:ListTagsForResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AccessAnalyzerListAccount",
            "Effect": "Allow",
            "Action": "access-analyzer:ListAnalyzers",
            "Resource": "*"
        }
    ]
}