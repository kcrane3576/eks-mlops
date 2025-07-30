{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "$IAM_WRITE_SCOPE_ROLES",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:TagRole",
        "iam:UntagRole"
      ],
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/vpc-flow-log-role-*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "$ENVIRONMENT"
        }
      }
    },
    {
      "Sid": "$IAM_WRITE_SCOPE_POLICIES",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:TagPolicy",
        "iam:UntagPolicy"
      ],
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:policy/vpc-flow-log-to-cloudwatch-*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "$ENVIRONMENT"
        }
      }
    },
    {
      "Sid": "$IAM_ATTACH_SCOPE_ROLE_POLICIES",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy"
      ],
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/vpc-flow-log-role-*"
    },
    {
      "Sid": "$IAM_PASS_TO_WRITE_ROLE",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/$WRITE_ROLE_ARN"
    }
  ]
}
