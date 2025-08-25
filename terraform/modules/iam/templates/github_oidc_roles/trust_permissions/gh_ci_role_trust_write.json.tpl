{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
				},
				"StringLike": {
					"token.actions.githubusercontent.com:sub": [
						"repo:${REPO_OWNER}/${REPO_NAME}:pull_request",
						"repo:${REPO_OWNER}/${REPO_NAME}:ref:refs/heads/main"
					]
				}
			}
		},
		{
			"Sid": "AllowAssumeFromOrchestrator",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${ORCHESTRATOR_ROLE_ARN}"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "ci-orchestrator-dev"
                }
            }
        }
	]
}