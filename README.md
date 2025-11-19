# CourseBundler - AWS Deployment Guide

## 📋 Project Overview

CourseBundler is a full-stack online learning platform deployed on AWS with a resilient, performant, and scalable architecture using:

- **Backend**: Node.js/Express with MongoDB, Redis caching
- **Frontend**: React.js with Redux
- **Infrastructure**: AWS ECS Fargate, ALB, ElastiCache, S3, CloudFront
- **Infrastructure as Code**: Terraform

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet Users                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                ┌────────────────┐
                │  CloudFront    │
                │     (CDN)      │
                └────────┬───────┘
                         │
                         ▼
        ┌──────────────────────────────────────────┐
        │   Application Load Balancer (ALB)        │
        │   Health Checks: /api/v1/health          │
        └────────┬──────────────────────┬──────────┘
                 │                      │
                 ▼                      ▼
        ┌─────────────────┐    ┌─────────────────┐
        │   ECS Fargate   │    │   ECS Fargate   │
        │   Backend Task  │    │   Backend Task  │
        │   (Auto Scale)  │    │   (Auto Scale)  │
        └────────┬─────────┘    └────────┬────────┘
                 │                       │
                 └───────────┬───────────┘
                             │
                 ┌───────────┴───────────┐
                 │                       │
                 ▼                       ▼
        ┌─────────────────┐    ┌─────────────────┐
        │  ElastiCache    │    │  MongoDB Atlas  │
        │  Redis Cluster  │    │   (External)    │
        │  (Multi-AZ)     │    │                 │
        └─────────────────┘    └─────────────────┘

        ┌──────────────────────────────────────────┐
        │         VPC (Multi-AZ)                   │
        │  - Public Subnets (ALB)                   │
        │  - Private Subnets (ECS, Redis)           │
        │  - NAT Gateway                            │
        └──────────────────────────────────────────┘

        ┌──────────────────────────────────────────┐
        │         CloudWatch Monitoring             │
        │  - Logs, Metrics, Alarms                  │
        │  - SNS Email Alerts                       │
        └──────────────────────────────────────────┘
```

---

## 📦 Prerequisites

Before deploying, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws --version
   aws configure
   ```
3. **Terraform** >= 1.0 installed
   ```bash
   terraform --version
   ```
4. **Docker** installed
   ```bash
   docker --version
   ```
5. **Node.js** and npm (for local development)
   ```bash
   node --version
   npm --version
   ```

---

## 🚀 Step-by-Step Deployment Instructions

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd Final_Project
```

### Step 2: Configure AWS Credentials

You have two options to configure AWS credentials:

#### Option 1: AWS CLI (Recommended)
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-west-1)
# Enter default output format (json)
```

#### Option 2: Setup Script (For Local Development)
```bash
# Copy the setup script template
cp .aws_credentials_setup.sh.example .aws_credentials_setup.sh

# Edit the file with your actual credentials
nano .aws_credentials_setup.sh

# Source the credentials
source .aws_credentials_setup.sh
```

**Important**: The `.aws_credentials_setup.sh` file is excluded from git by `.gitignore` for security reasons. Never commit actual AWS credentials to version control.

### Step 3: Update Terraform Variables

1. Copy the example variables file:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
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

### Step 4: Initialize Terraform

```bash
cd terraform
terraform init
```

This will download required providers and initialize the backend.

### Step 5: Review Terraform Plan

```bash
terraform plan
```

Review the execution plan to see what resources will be created.

### Step 6: Apply Terraform Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- VPC with public/private subnets
- ECR repository
- ElastiCache Redis cluster
- Application Load Balancer
- ECS cluster and service
- S3 bucket and CloudFront distribution
- CloudWatch monitoring and alarms

**Expected Time**: 15-30 minutes for initial deployment

### Step 7: Build and Push Docker Image

After infrastructure is deployed, get the ECR repository URL:

```bash
terraform output ecr_repository_url
```

Then build and push your backend image:

```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build backend image
cd ../backend
docker build -t coursebundler-backend:latest .

# Tag image
docker tag coursebundler-backend:latest $(terraform -chdir=../terraform output -raw ecr_repository_url):latest

# Push image
docker push $(terraform -chdir=../terraform output -raw ecr_repository_url):latest
```

### Step 8: Update ECS Service

The ECS service will automatically pull the new image. If needed, force a new deployment:

```bash
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service coursebundler-dev-service \
  --force-new-deployment \
  --region us-east-1
```

### Step 9: Build and Deploy Frontend

1. Update frontend environment variable:
   ```bash
   cd ../frontend
   # Get ALB DNS name
   ALB_DNS=$(terraform -chdir=../terraform output -raw alb_dns_name)
   echo "REACT_APP_API_URL=http://${ALB_DNS}/api/v1" > .env.production
   ```

2. Build frontend:
   ```bash
   npm run build
   ```

3. Upload to S3:
   ```bash
   BUCKET_NAME=$(terraform -chdir=../terraform output -raw frontend_bucket_name)
   aws s3 sync build/ s3://${BUCKET_NAME} --delete
   ```

4. Invalidate CloudFront cache:
   ```bash
   DISTRIBUTION_ID=$(terraform -chdir=../terraform output -raw cloudfront_distribution_id)
   aws cloudfront create-invalidation \
     --distribution-id ${DISTRIBUTION_ID} \
     --paths "/*"
   ```

---

## 🔧 Environment Variables

### Backend Environment Variables

Required in `backend/config/config.env`:

```env
PORT=5001
MONGO_URI=mongodb+srv://...
JWT_SECRET=...
FRONTEND_URL=http://localhost:3000
REDIS_HOST=localhost
REDIS_PORT=6379
AWS_REGION=us-east-1
# ... other variables
```

### Frontend Environment Variables

- **Development**: `frontend/.env.development`
  ```
  REACT_APP_API_URL=http://localhost:5001/api/v1
  ```

- **Production**: `frontend/.env.production`
  ```
  REACT_APP_API_URL=http://YOUR-ALB-DNS-NAME/api/v1
  ```

---

## 🌐 URLs After Deployment

After successful deployment, you'll get these URLs:

```bash
# Get all outputs
terraform output

# ALB DNS Name (Backend API)
terraform output alb_dns_name
# Example: coursebundler-dev-alb-123456789.us-east-1.elb.amazonaws.com

# CloudFront URL (Frontend)
terraform output cloudfront_url
# Example: https://d1234567890abc.cloudfront.net

# ECR Repository URL
terraform output ecr_repository_url

# Redis Endpoint (for reference)
terraform output redis_endpoint
```

**Access Points:**
- **Frontend**: Use CloudFront URL
- **Backend API**: Use ALB DNS name
- **Health Check**: `http://ALB-DNS/api/v1/health`

---

## 💰 Cost Estimates

Estimated monthly costs (varies with usage):

| Service | Estimated Cost |
|---------|---------------|
| ECS Fargate (2-6 tasks) | $50-200 |
| Application Load Balancer | $20 |
| ElastiCache Redis (cache.t3.micro x2) | $15-30 |
| NAT Gateway | $35 |
| S3 + CloudFront | $10-50 |
| CloudWatch | $10-20 |
| **Total** | **$140-355/month** |

**Cost Optimization Tips:**
- Use Fargate Spot for non-critical workloads
- Scale down during off-hours
- Enable S3 lifecycle policies
- Use CloudFront caching effectively

---

## 🐳 Local Testing with Docker Compose

Test the application locally before deploying:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

**Services:**
- Backend: http://localhost:5001
- Frontend: http://localhost:3000
- Redis: localhost:6379

---

## 🔍 Monitoring and Troubleshooting

### View CloudWatch Logs

```bash
# ECS container logs
aws logs tail /ecs/coursebundler-dev --follow --region us-east-1
```

### Check ECS Service Status

```bash
aws ecs describe-services \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --services coursebundler-dev-service \
  --region us-east-1
```

### Check Auto Scaling

```bash
aws application-autoscaling describe-scalable-targets \
  --service-namespace ecs \
  --region us-east-1
```

### View CloudWatch Alarms

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix coursebundler-dev \
  --region us-east-1
```

### Common Issues

1. **ECS Tasks Not Starting**
   - Check CloudWatch logs
   - Verify ECR image exists
   - Check security groups
   - Verify task definition

2. **ALB Health Checks Failing**
   - Verify health endpoint: `/api/v1/health`
   - Check security groups allow traffic
   - Verify containers are listening on correct port

3. **Redis Connection Issues**
   - Verify ElastiCache security group allows ECS traffic
   - Check Redis endpoint in environment variables
   - Verify VPC configuration

4. **Auto Scaling Not Working**
   - Check CloudWatch metrics
   - Verify auto scaling policies are attached
   - Check service desired count

---

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**Warning**: This will delete all resources including databases and data. Make sure you have backups!

---

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ElastiCache Best Practices](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/best-practices.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)

---

## 📝 Project Structure

```
Final_Project/
├── backend/              # Node.js backend
│   ├── Dockerfile
│   ├── config/
│   ├── controllers/
│   ├── models/
│   └── routes/
├── frontend/             # React frontend
│   ├── Dockerfile
│   ├── src/
│   └── .env.development
├── terraform/            # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── ecs/
│       ├── ecr/
│       ├── alb/
│       ├── cache/
│       ├── storage/
│       └── monitoring/
├── docker-compose.yml    # Local testing
└── README.md            # This file
```

---

## ✅ Deployment Checklist

- [ ] AWS credentials configured
- [ ] Terraform variables updated
- [ ] Infrastructure deployed (`terraform apply`)
- [ ] Docker image built and pushed to ECR
- [ ] ECS service running and healthy
- [ ] Frontend built and uploaded to S3
- [ ] CloudFront cache invalidated
- [ ] Health checks passing
- [ ] Monitoring alerts configured
- [ ] Documentation reviewed

---

**Last Updated**: 2024  
**Version**: 1.0

