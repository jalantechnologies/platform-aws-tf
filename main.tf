terraform {
  # Using local state file instead of Terraform Cloud
  # Cloud configuration commented out for local development
  # cloud {
  #   organization = "jalantechnologies"
  #   workspaces {
  #     name = "platform-aws-cluster-tf"
  #   }
  # }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_ca_certificate)
  token                  = module.aws_eks.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_ca_certificate)
    token                  = module.aws_eks.cluster_token
  }
}

provider "kubectl" {
  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_ca_certificate)
  token                  = module.aws_eks.cluster_token
  load_config_file       = false
}

module "aws_eks" {
  source                = "./modules/aws-eks"
  cluster_name          = var.cluster_name
  cluster_version       = var.cluster_version
  aws_region           = var.aws_region
  alert_email          = var.alert_email
  production_node_size = var.production_node_size
  staging_node_size    = var.staging_node_size
}

module "kubernetes" {
  depends_on           = [module.aws_eks]
  source               = "./modules/kubernetes"
  cluster_issuer_email = var.cluster_issuer_email
  cluster_issuer_name  = "letsencrypt-prod"
  cluster_name         = var.cluster_name
  aws_region          = var.aws_region
  vpc_id              = module.aws_eks.vpc_id
}
