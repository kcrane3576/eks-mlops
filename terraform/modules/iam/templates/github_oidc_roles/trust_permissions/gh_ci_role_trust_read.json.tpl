{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
					"token.actions.githubusercontent.com:repository": "$REPO_OWNER/$REPO_NAME",
					"token.actions.githubusercontent.com:sub": "repo:$REPO_OWNER/$REPO_NAME:environment:$ENVIRONMENT:pull_request"
				}
			}
		}
	]
}