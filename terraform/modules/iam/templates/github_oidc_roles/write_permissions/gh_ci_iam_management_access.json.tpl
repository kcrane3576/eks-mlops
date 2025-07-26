{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "$IAM_MANAGE_SCOPE_ROLES",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/vpc-flow-log-role-*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "$ENVIRONMENT"
        }
      }
    },
    {
      "Sid": "$IAM_MANAGE_SCOPE_POLICIES",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:TagPolicy",
        "iam:UntagPolicy",
        "iam:ListPolicyVersions"
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
