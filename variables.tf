variable "aws_region" {
  description = "The AWS region to deploy the EKS cluster in."
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Profile to use for obtaining AWS credentials"
  default     = "jalantechnologies"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  default     = "platform-k8-cluster"
}

variable "eks_instance_type" {
  description = "Instance to use with EKS cluster nodes."
  default     = "t3.medium"
}

variable "eks_desired_capacity" {
  description = "The desired number of worker nodes for EKS cluster."
  default     = 2
}

variable "eks_max_capacity" {
  description = "The maximum number of worker nodes for EKS cluster."
  default     = 3
}

variable "eks_min_capacity" {
  description = "The minimum number of worker nodes for EKS cluster."
  default     = 1
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository."
  default     = "platform"
}

variable "cert_issuer_email" {
  description = "Email to use with cert manager for issuing SSL certificates"
  default     = "developer@jalantechnologies.com"
}
