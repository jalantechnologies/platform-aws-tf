# Terraform - AWS EKS

This project is a template for setting up a Kubernetes cluster on AWS using Amazon EKS (Elastic Kubernetes Service). It's migrated from the DigitalOcean version to provide equivalent functionality using AWS services.

## Architecture

### AWS Services Used:
- **Amazon EKS**: Managed Kubernetes service
- **EC2**: Worker nodes for the Kubernetes cluster
- **VPC**: Virtual Private Cloud with public/private subnets
- **Application Load Balancer**: For ingress traffic (via AWS Load Balancer Controller)
- **CloudWatch**: Monitoring and alerting
- **SNS**: Email notifications for alerts
- **IAM**: Roles and policies for service authentication

### Kubernetes Components:
- **NGINX Ingress Controller**: HTTP/HTTPS ingress
- **Cert-Manager**: Automatic SSL certificate management with Let's Encrypt
- **Doppler Operator**: Secrets management
- **AWS Load Balancer Controller**: Native AWS load balancer integration

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform CLI** installed
3. **kubectl** installed for cluster management
4. **AWS IAM permissions** for EKS, EC2, VPC, CloudWatch, SNS, and IAM operations

## Required AWS IAM Policy

Before running Terraform, create the AWS Load Balancer Controller IAM policy:

```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

## Setup Steps

1. **Configure Terraform Cloud**
   - Request access to organization's Terraform Cloud account
   - Update the organization name in `main.tf` if different

2. **Login to Terraform**
   ```bash
   terraform login
   ```

3. **Set Variables**
   Create a `terraform.tfvars` file or set variables in Terraform Cloud:
   ```hcl
   cluster_name         = "my-eks-cluster"
   aws_region          = "us-east-1"
   cluster_version     = "1.28"
   alert_email         = "alerts@yourcompany.com"
   cluster_issuer_email = "ssl@yourcompany.com"
   production_node_size = "t3.medium"
   staging_node_size   = "t3.medium"
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region <your-region> --name <cluster-name>
   ```

## Key Differences from DigitalOcean Version

### Infrastructure:
- **VPC Setup**: Creates custom VPC with public/private subnets and NAT gateways
- **Security Groups**: Automatic security group management for EKS
- **IAM Roles**: Service roles for EKS cluster and node groups
- **Load Balancer**: Uses AWS Application Load Balancer instead of DigitalOcean Load Balancer

### Monitoring:
- **CloudWatch**: Replaces DigitalOcean Monitoring
- **SNS**: Email notifications instead of direct email alerts
- **Metrics**: CPU and memory utilization monitoring on EC2 instances

### Networking:
- **Ingress**: Uses AWS Load Balancer Controller for native AWS integration
- **DNS**: Can integrate with Route53 for DNS management
- **SSL**: Cert-Manager works with AWS Load Balancers for SSL termination

## Instance Types

The default instance types are equivalent to DigitalOcean's `s-2vcpu-4gb`:
- **t3.medium**: 2 vCPUs, 4GB RAM (similar to DO's s-2vcpu-4gb)

You can modify instance types in variables:
- `t3.small`: 2 vCPUs, 2GB RAM
- `t3.large`: 2 vCPUs, 8GB RAM
- `t3.xlarge`: 4 vCPUs, 16GB RAM

## Monitoring and Alerts

CloudWatch alarms are configured for:
- **CPU Utilization**: Alert when >90% for 10 minutes
- **Memory Utilization**: Alert when >90% for 10 minutes (requires CloudWatch agent)

Alerts are sent via SNS to the configured email address.

## Cost Optimization

- **Node Groups**: Auto-scaling from 1-2 nodes per environment
- **Spot Instances**: Can be enabled for cost savings (modify node group configuration)
- **Resource Limits**: Set appropriate resource requests/limits in Kubernetes

## Troubleshooting

### Common Issues:

1. **AWS Load Balancer Controller Issues**:
   ```bash
   kubectl logs -n kube-system deployment/aws-load-balancer-controller
   ```

2. **EKS Token Refresh**:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

3. **Node Group Issues**:
   ```bash
   kubectl get nodes
   kubectl describe node <node-name>
   ```

### Useful Commands:

```bash
# Check cluster status
kubectl cluster-info

# View all pods
kubectl get pods --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces

# View load balancer services
kubectl get svc --all-namespaces -o wide
```

## Preview Environments (Branch-based)

The infrastructure supports branch-based preview environments through:

- **ECR Repositories**: Separate staging repository for preview builds
- **Node Groups**: Staging node group for preview workloads
- **Namespace Isolation**: Kubernetes namespaces for environment separation
- **Ingress Routing**: Dynamic routing based on branch names

### Setting up Preview Environments:

1. **Build Process**: Push images to staging ECR with branch tags
   ```bash
   docker tag myapp:latest ${ECR_STAGING_URL}:${BRANCH_NAME}
   docker push ${ECR_STAGING_URL}:${BRANCH_NAME}
   ```

2. **Deploy to Staging**: Use Kubernetes namespaces for isolation
   ```bash
   kubectl create namespace preview-${BRANCH_NAME}
   kubectl apply -f manifests/ -n preview-${BRANCH_NAME}
   ```

3. **Ingress Configuration**: Route traffic based on subdomain
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: preview-${BRANCH_NAME}
   spec:
     rules:
     - host: ${BRANCH_NAME}.preview.yourdomain.com
   ```

## Security Considerations

- **Private Subnets**: Worker nodes are in private subnets
- **Security Groups**: Restrictive security group rules
- **IAM Roles**: Least privilege access for services
- **Encryption**: EKS encryption at rest can be enabled
- **Network Policies**: Can be implemented for pod-to-pod communication
- **ECR Security**: Image scanning enabled on push

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

**Note**: Ensure all Kubernetes resources (especially LoadBalancer services) are deleted before running `terraform destroy` to avoid orphaned AWS resources.
