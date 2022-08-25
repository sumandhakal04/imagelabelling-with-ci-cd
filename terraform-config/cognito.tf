resource "aws_cognito_identity_pool" "s3" {
  identity_pool_name               = "s3-identity pool"
  allow_unauthenticated_identities = true
  allow_classic_flow               = false
}

resource "aws_iam_policy" "s3-access-cognito" {
  name        = "s3-access-cognito"
  description = "s3-access-cognito"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "auth_iam_role" {
  name               = "auth_iam_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "cognito-identity.amazonaws.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.s3.id}"
                },
                "ForAnyValue:StringLike": {
                    "cognito-identity.amazonaws.com:amr": "authenticated"
                }
            }
        }
    ]  
    }
EOF
}

resource "aws_iam_role_policy_attachment" "cognito-s3-attach" {
  role       = aws_iam_role.unauth_iam_role.name
  policy_arn = aws_iam_policy.s3-access-cognito.arn
}

resource "aws_iam_role" "unauth_iam_role" {
  name               = "unauth_iam_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "cognito-identity.amazonaws.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.s3.id}"
                },
                "ForAnyValue:StringLike": {
                    "cognito-identity.amazonaws.com:amr": "unauthenticated"
                }
            }
        }
    ]  
    }
EOF
}

resource "aws_iam_role_policy" "web_iam_unauth_role_policy" {
  name   = "web_iam_unauth_role_policy"
  role   = aws_iam_role.unauth_iam_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "mobileanalytics:PutEvents",
                "cognito-sync:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "cognito-image-labeller" {
  name   = "cognito-image-labeller"
  role   = aws_iam_role.auth_iam_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "mobileanalytics:PutEvents",
                "cognito-sync:*",
                "cognito-identity:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.s3.id

  roles = {
    authenticated   = aws_iam_role.auth_iam_role.arn
    unauthenticated = aws_iam_role.unauth_iam_role.arn
  }
}