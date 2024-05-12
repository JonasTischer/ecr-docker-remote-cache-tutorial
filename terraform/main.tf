provider "aws" {
  region = "eu-central-1" // Change this to your desired region
}

# Create the GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:JonasTischer/*"] // Change this to your GitHub organization
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}


data "aws_iam_policy_document" "deploy" {
  statement {
    effect  = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "github" {
  name               = "github_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.oidc.json
}

resource "aws_iam_policy" "deploy" {
  name        = "ci-deploy-policy"
  description = "Policy used for deployments on CI"
  policy      = data.aws_iam_policy_document.deploy.json
}

resource "aws_iam_role_policy_attachment" "attach-deploy" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.deploy.arn
}

# Create the ECR repository
resource "aws_ecr_repository" "my_simple_app" {
  name                 = "my-simple-app"
  image_tag_mutability = "MUTABLE"
}

# Output the ECR repository URI
output "ecr_repository_uri" {
  value = aws_ecr_repository.my_simple_app.repository_url
}