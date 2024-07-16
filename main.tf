terraform {
  cloud {
    organization = "jalantechnologies"
    workspaces {
      name = "platform-aws-tf"
    }
  }
}

locals {
  eks_auth_args = [
    "eks",
    "get-token",
    "--cluster-name",
    module.eks.cluster_name,
    "--region",
    var.aws_region,
    "--profile",
    var.aws_profile,
  ]
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = local.eks_auth_args
    command     = "aws"
  }
}

provider "helm" {
  debug = true

  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = local.eks_auth_args
      command     = "aws"
    }
  }
}
