# Terraform Infrastructure as Code

This directory contains Terraform configuration for deploying CourseBundler on AWS.

## Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf           # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars.example # Example variables file
└── modules/
    ├── vpc/                # VPC and networking
    ├── security-groups/    # Security group configurations
    ├── ecr/                # ECR repositories
    ├── database/           # DocumentDB cluster
    ├── alb/                # Application Load Balancer
    ├── ecs/                # ECS cluster and services
    ├── s3/                 # S3 bucket for static assets
    ├── cloudfront/         # CloudFront distribution
    ├── cloudwatch/         # CloudWatch monitoring
    └── autoscaling/        # Auto scaling configuration
```

## Quick Start

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update variables in `terraform.tfvars`
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`

## Modules

### VPC Module
Creates VPC with:
- 3 Availability Zones
- Public and private subnets
- Internet Gateway
- NAT Gateways (one per AZ)
- Route tables

### Security Groups Module
Creates security groups for:
- ALB (HTTP/HTTPS)
- Backend ECS tasks
- Frontend ECS tasks
- DocumentDB

### ECR Module
Creates ECR repositories for:
- Backend Docker images
- Frontend Docker images

### Database Module
Creates:
- DocumentDB cluster (Multi-AZ)
- DocumentDB instances
- Subnet group
- Parameter group
- Secrets Manager secret for password

### ALB Module
Creates:
- Application Load Balancer
- Target groups (backend and frontend)
- Listeners (HTTP and HTTPS)
- Listener rules

### ECS Module
Creates:
- ECS cluster
- Task definitions (backend and frontend)
- ECS services
- IAM roles
- CloudWatch log groups

### S3 Module
Creates:
- S3 bucket for static assets
- Versioning
- Encryption
- Lifecycle policies

### CloudFront Module
Creates:
- CloudFront distribution
- Origin access control
- Cache behaviors
- Custom error responses

### CloudWatch Module
Creates:
- Log groups
- Metric alarms
- Auto-recovery triggers

### Auto Scaling Module
Creates:
- Auto scaling targets
- Scaling policies (CPU and memory)
- Target tracking configurations

## Variables

See `variables.tf` for all available variables.

## Outputs

Key outputs:
- `alb_dns_name`: ALB DNS name
- `cloudfront_domain`: CloudFront distribution domain
- `documentdb_endpoint`: DocumentDB endpoint
- `ecr_backend_repository_url`: Backend ECR repository URL
- `ecr_frontend_repository_url`: Frontend ECR repository URL

## State Management

Terraform state is stored in S3 (configure in `main.tf` backend block).

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Random Provider >= 3.0

## Notes

- DocumentDB password is automatically generated and stored in Secrets Manager
- ECS tasks use Fargate (serverless)
- Minimum 2 tasks per service for high availability
- Auto scaling based on CPU and memory utilization
- CloudWatch alarms trigger on high utilization and unhealthy tasks

