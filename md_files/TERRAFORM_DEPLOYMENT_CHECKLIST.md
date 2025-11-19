# Terraform AWS Deployment Checklist

## Required Information

### 1. AWS Credentials
- **AWS Access Key ID** - For programmatic access
- **AWS Secret Access Key** - Keep this secure!
- **AWS Account ID** (optional but helpful)

### 2. AWS Configuration
- **AWS Region** (default: us-east-1)
- **Availability Zones** (default: us-east-1a, us-east-1b)

### 3. Application Configuration
- **Project Name** (default: coursebundler)
- **Environment** (dev/staging/prod)
- **Alert Email** - For CloudWatch notifications

### 4. Optional Customizations
- **Container CPU** (default: 512)
- **Container Memory** (default: 1024)
- **Desired Task Count** (default: 2)
- **Min/Max Capacity** for auto-scaling (default: 2-6)

## What I'll Help You With

1. ✅ Create terraform.tfvars file with your values
2. ✅ Verify AWS credentials are configured
3. ✅ Initialize Terraform
4. ✅ Review the deployment plan
5. ✅ Deploy infrastructure step by step
6. ✅ Get deployment outputs (ALB URL, CloudFront URL, etc.)
7. ✅ Build and push Docker images to ECR
8. ✅ Deploy frontend to S3/CloudFront

## Estimated Costs

- ECS Fargate: ~$50-200/month
- ALB: ~$20/month
- ElastiCache Redis: ~$15-30/month
- NAT Gateway: ~$35/month
- S3 + CloudFront: ~$10-50/month
- CloudWatch: ~$10-20/month
- **Total: ~$140-355/month**

## Prerequisites Check

Before we start, make sure you have:
- [ ] AWS CLI installed (`aws --version`)
- [ ] Terraform installed (`terraform --version`)
- [ ] Docker installed (for building images)
- [ ] AWS account with appropriate permissions
- [ ] AWS credentials configured or ready to configure

