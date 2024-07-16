# Get current AWS account ID
data "aws_caller_identity" "current" {}

resource "aws_iam_user" "iam_eks_deployer" {
  name = "${module.eks.cluster_name}-deployer"
}

resource "kubernetes_config_map_v1_data" "eks_deployer_auth" {
  depends_on = [aws_iam_user.iam_eks_deployer]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = <<EOF
- userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.iam_eks_deployer.name}
  username: ${aws_iam_user.iam_eks_deployer.name}
  groups:
    - system:masters
EOF
  }
}

resource "aws_iam_access_key" "iam_eks_deployer_access" {
  user = aws_iam_user.iam_eks_deployer.name
}

resource "aws_iam_user_policy" "iam_eks_deployer_policy" {
  name = "${aws_iam_user.iam_eks_deployer.name}-policy"
  user = aws_iam_user.iam_eks_deployer.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "eks:DescribeCluster",
        Resource = module.eks.cluster_arn
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:BatchDeleteImage",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = module.ecr.repository_arn
      },
      {
        Effect   = "Allow",
        Action   = "ecr:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

output "iam_eks_deployer_access_id" {
  value = aws_iam_access_key.iam_eks_deployer_access.id
}

output "iam_eks_deployer_access_secret" {
  value     = aws_iam_access_key.iam_eks_deployer_access.secret
  sensitive = true
}
