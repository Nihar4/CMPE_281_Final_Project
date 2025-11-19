# CourseBundler - AWS Deployment Guide

## Project Overview

CourseBundler is a full-stack online learning platform deployed on AWS. The stack includes Node.js/Express backend with MongoDB and Redis caching, React.js frontend, and infrastructure managed with Terraform on AWS ECS Fargate.

---

## Prerequisites

Before deploying, ensure you have:

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Terraform >= 1.0
- Docker installed
- Node.js and npm

---

## Quick Start - Deployment Steps

### 1. Clone Repository

```bash
git clone <your-repo-url>
cd Final_Project
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter output format (json)
```

### 3. Setup Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_name = "coursebundler"
environment  = "dev"
aws_region   = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
container_port = 5001
desired_count = 2
min_capacity  = 2
max_capacity  = 6
alert_email   = "your-email@example.com"
```

### 4. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. Deployment takes 15-30 minutes.

### 5. Build and Push Backend Image

Get ECR repository URL:

```bash
terraform output ecr_repository_url
```

Build and push Docker image:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

cd ../backend
docker build -t coursebundler-backend:latest .
docker tag coursebundler-backend:latest $(terraform -chdir=../terraform output -raw ecr_repository_url):latest
docker push $(terraform -chdir=../terraform output -raw ecr_repository_url):latest
```

### 6. Deploy Frontend

```bash
cd ../frontend

# Create environment file with ALB DNS
ALB_DNS=$(terraform -chdir=../terraform output -raw alb_dns_name)
echo "REACT_APP_API_URL=http://${ALB_DNS}/api/v1" > .env.production

# Build and upload to S3
npm run build
BUCKET_NAME=$(terraform -chdir=../terraform output -raw frontend_bucket_name)
aws s3 sync build/ s3://${BUCKET_NAME} --delete

# Invalidate CloudFront cache
DISTRIBUTION_ID=$(terraform -chdir=../terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"
```

---

## Environment Variables

### Backend (`backend/config/config.env`)

```env
PORT=5001
MONGO_URI=mongodb+srv://...
JWT_SECRET=your-secret
FRONTEND_URL=http://localhost:3000
REDIS_HOST=your-redis-endpoint
REDIS_PORT=6379
AWS_REGION=us-east-1
```

### Frontend (`frontend/.env.production`)

```
REACT_APP_API_URL=http://YOUR-ALB-DNS-NAME/api/v1
```

---

## Access Your Application

After deployment, get your URLs:

```bash
terraform output
```

- **Frontend**: CloudFront URL
- **Backend API**: ALB DNS name
- **Health Check**: `http://ALB-DNS/api/v1/health`

---

## Local Testing

Test locally with Docker Compose before deploying:

```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

---

## Monitoring

### View Logs

```bash
aws logs tail /ecs/coursebundler-dev --follow --region us-east-1
```

### Check Service Status

```bash
aws ecs describe-services \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --services coursebundler-dev-service \
  --region us-east-1
```

### Common Issues

- **ECS Tasks Not Starting**: Check CloudWatch logs, verify ECR image exists, check security groups
- **ALB Health Checks Failing**: Verify `/api/v1/health` endpoint, check security groups allow traffic
- **Redis Connection Issues**: Verify ElastiCache security group, check endpoint in environment variables

---

## Cleanup

To delete all resources:

```bash
cd terraform
terraform destroy
```

⚠️ **Warning**: This permanently deletes all resources including databases and data.

---
