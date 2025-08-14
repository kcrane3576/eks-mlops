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
            "Resource": "arn:aws:access-analyzer:${REGION}:${AWS_ACCOUNT_ID}:analyzer/${REPO_NAME}-access-analyzer"
        },
        {
            "Sid": "AccessAnalyzerListAccount",
            "Effect": "Allow",
            "Action": "access-analyzer:ListAnalyzers",
            "Resource": "*"
        }
    ]
}