{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IAMManageNodeGroupRoles",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:TagRole",
                "iam:PassRole",
                "iam:ListInstanceProfilesForRole",
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/*"
        },
        {
            "Sid": "IAMManageOIDCProviders",
            "Effect": "Allow",
            "Action": [
                "iam:CreateOpenIDConnectProvider",
                "iam:DeleteOpenIDConnectProvider",
                "iam:ListOpenIDConnectProviders",
                "iam:TagOpenIDConnectProvider"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMManagePoliciesInAccount",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:DeletePolicy",
                "iam:TagPolicy",
                "iam:GetPolicy",
                "iam:ListPolicyVersions"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/*"
        },
        {
            "Sid": "IAMGetWriteRole",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "${WRITE_ROLE_ARN}"
        },
        {
            "Sid": "LogsCreateGroupForCluster",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LogsTagOnCreateForClusterGroup",
            "Effect": "Allow",
            "Action": "logs:TagResource",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Name": "${CLUSTER_NAME}",
                    "aws:RequestTag/Repo": "${REPO_NAME}",
                    "aws:RequestTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "LogsManageOnlyThisClusterGroup",
            "Effect": "Allow",
            "Action": [
                "logs:DeleteLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/eks/${CLUSTER_NAME}/cluster",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Name": "${CLUSTER_NAME}",
                    "aws:ResourceTag/Repo": "${REPO_NAME}",
                    "aws:ResourceTag/Environment": "${ENVIRONMENT}"
                }
            }
        },
        {
            "Sid": "EC2ManageEKSSecurityGroupsAndTemplates",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:DescribeLaunchTemplates",
                "ec2:DeleteLaunchTemplate"
            ],
            "Resource": "*"
        },
        {
            "Sid": "KMSManageKeysAndAliases",
            "Effect": "Allow",
            "Action": [
                "kms:CreateKey",
                "kms:TagResource",
                "kms:CreateAlias",
                "kms:DeleteAlias",
                "kms:ListAliases"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EKSFullClusterAndAddonManagement",
            "Effect": "Allow",
            "Action": [
                "eks:CreateCluster",
                "eks:DeleteCluster",
                "eks:DescribeCluster",
                "eks:TagResource",
                "eks:UntagResource",
                "eks:ListClusters",
                "eks:CreateNodegroup",
                "eks:DeleteNodegroup",
                "eks:ListNodegroups",
                "eks:CreateAccessEntry",
                "eks:ListAccessEntries",
                "eks:DeleteAccessEntry",
                "eks:AssociateAccessPolicy",
                "eks:DisassociateAccessPolicy",
                "eks:ListAccessPolicies",
                "eks:CreateAddon",
                "eks:UpdateAddon",
                "eks:DeleteAddon",
                "eks:ListAddons"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMInstanceProfileForBastion",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:TagInstanceProfile"
            ],
            "Resource": "*"
        }
    ]
}