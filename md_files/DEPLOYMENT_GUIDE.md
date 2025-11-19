# AWS Deployment Guide - CourseBundler Final Project

## ✅ Configuration Complete

### Your Settings:
- **Project Name**: coursebundler_final_project
- **AWS Region**: us-west-1
- **Account ID**: 799416476754
- **Alert Email**: nihardharmeshkumar.patel@sjsu.edu
- **Environment**: dev

### Cost-Optimized Configuration:
- **ECS CPU**: 256 (0.25 vCPU) - Lowest tier
- **ECS Memory**: 512 MB - Lowest tier
- **Tasks**: 1-2 (minimal for cost)
- **Redis**: Single node (cache.t3.micro)
- **Auto-scaling**: 1-2 tasks only

### Estimated Monthly Cost: ~$80-120
(Reduced from $140-355 with optimizations)

## Deployment Steps

### 1. Set AWS Credentials
```bash
source .aws_credentials_setup.sh
```

### 2. Initialize Terraform
```bash
cd terraform
terraform init
```

### 3. Review Deployment Plan
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted.

### 5. Get Deployment Outputs
```bash
terraform output
```

### 6. Build and Push Docker Image
```bash
# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin $ECR_URL

# Build and push backend
cd ../backend
docker build -t coursebundler-backend:latest .
docker tag coursebundler-backend:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 7. Deploy Frontend
```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Update frontend env
cd ../frontend
echo "REACT_APP_API_URL=http://${ALB_DNS}/api/v1" > .env.production

# Build frontend
npm run build

# Upload to S3
BUCKET=$(terraform output -raw frontend_bucket_name)
aws s3 sync build/ s3://$BUCKET --delete

# Invalidate CloudFront
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

## Important URLs After Deployment

- **Frontend**: CloudFront URL (from terraform output)
- **Backend API**: ALB DNS name (from terraform output)
- **Health Check**: http://ALB-DNS/api/v1/health

## Cleanup (When Done)

```bash
cd terraform
terraform destroy
```

⚠️ **Warning**: This will delete all resources and data!

