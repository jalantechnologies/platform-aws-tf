# Variables cluster_issuer_email and cluster_issuer_name are defined in cert-manager.tf
# Keeping other variables that are unique to this module

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}
