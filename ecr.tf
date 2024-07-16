module "ecr" {
  source                          = "terraform-aws-modules/ecr/aws"
  repository_name                 = var.ecr_repository_name
  repository_image_tag_mutability = "MUTABLE"

  repository_read_access_arns = [module.eks.cluster_iam_role_arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus   = "tagged",
          tagPrefixList = ["v"],
          countType   = "imageCountMoreThan",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
