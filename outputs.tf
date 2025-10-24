output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.aws_eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.aws_eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.aws_eks.cluster_security_group_id
}

output "ingress_nginx_service_external_ip" {
  description = "External IP of the ingress nginx service"
  value       = module.kubernetes.ingress_nginx_service_external_ip
}

output "ecr_app_repository_url" {
  description = "URL of the ECR repository for production apps"
  value       = module.aws_eks.ecr_app_repository_url
}

output "ecr_staging_repository_url" {
  description = "URL of the ECR repository for staging apps"
  value       = module.aws_eks.ecr_staging_repository_url
}
