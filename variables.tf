variable "cluster_issuer_email" {
  description = "Email address used for ACME registration for Kubernetes CertManager service"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name on AWS"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address to be used for sending resource utilization alerts"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "production_node_size" {
  description = "EC2 instance type for production node group"
  type        = string
  default     = "t3.medium"
}

variable "staging_node_size" {
  description = "EC2 instance type for staging node group"
  type        = string
  default     = "t3.medium"
}
