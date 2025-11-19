# CourseBundler - AWS Deployment Instructions

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** >= 1.0 installed
4. **Docker** installed
5. **Node.js** and npm installed (for local testing)

## Step 1: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (json)
```

## Step 2: Set Up Terraform Backend (Optional but Recommended)

Create an S3 bucket for Terraform state:

```bash
aws s3 mb s3://coursebundler-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket coursebundler-terraform-state \
  --versioning-configuration Status=Enabled
```

Update `terraform/main.tf` backend configuration:

```hcl
backend "s3" {
  bucket = "coursebundler-terraform-state"
  key    = "terraform.tfstate"
  region = "us-east-1"
}
```

## Step 3: Create SSL Certificates (Optional for HTTPS)

### For ALB (in your region):
```bash
# Request certificate via AWS Certificate Manager
aws acm request-certificate \
  --domain-name yourdomain.com \
  --validation-method DNS \
  --region us-east-1
```

### For CloudFront (must be in us-east-1):
```bash
aws acm request-certificate \
  --domain-name yourdomain.com \
  --validation-method DNS \
  --region us-east-1
```

Note the ARN of certificates and update `terraform/terraform.tfvars`

## Step 4: Configure Terraform Variables

Create `terraform/terraform.tfvars`:

```hcl
aws_region              = "us-east-1"
environment            = "prod"
project_name           = "coursebundler"
vpc_cidr               = "10.0.0.0/16"
db_instance_class      = "db.t3.medium"
db_instance_count      = 2
certificate_arn        = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT-ID"
cloudfront_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT-ID"
backend_min_capacity   = 2
backend_max_capacity   = 10
frontend_min_capacity  = 2
frontend_max_capacity  = 10
```

## Step 5: Build and Push Docker Images

### Build Backend Image

```bash
cd backend
docker build -t coursebundler-backend:latest .
docker tag coursebundler-backend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-backend-prod:latest
```

### Build Frontend Image

```bash
cd frontend
docker build -t coursebundler-frontend:latest .
docker tag coursebundler-frontend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-frontend-prod:latest
```

### Login to ECR and Push Images

```bash
# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Push backend image
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-backend-prod:latest

# Push frontend image
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-frontend-prod:latest
```

**Note**: ECR repositories will be created by Terraform. You can push images after infrastructure is deployed, or create repositories first:

```bash
# Create ECR repositories manually (or let Terraform create them)
aws ecr create-repository --repository-name coursebundler-backend-prod --region us-east-1
aws ecr create-repository --repository-name coursebundler-frontend-prod --region us-east-1
```

## Step 6: Store Secrets in AWS Secrets Manager

### Create JWT Secret

```bash
aws secretsmanager create-secret \
  --name coursebundler-prod-jwt-secret \
  --secret-string "your-jwt-secret-key-here" \
  --region us-east-1
```

### Create Other Secrets

```bash
# Razorpay API Key
aws secretsmanager create-secret \
  --name coursebundler-prod-razorpay-key \
  --secret-string "rzp_test_..." \
  --region us-east-1

# Razorpay API Secret
aws secretsmanager create-secret \
  --name coursebundler-prod-razorpay-secret \
  --secret-string "your-razorpay-secret" \
  --region us-east-1

# Cloudinary credentials
aws secretsmanager create-secret \
  --name coursebundler-prod-cloudinary-config \
  --secret-string '{"cloud_name":"...","api_key":"...","api_secret":"..."}' \
  --region us-east-1
```

**Note**: DocumentDB password will be automatically created by Terraform and stored in Secrets Manager.

## Step 7: Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

Type `yes` when prompted to create resources.

**Expected Time**: 15-30 minutes for initial deployment

## Step 8: Update ECS Task Definitions with Secrets

After infrastructure is deployed, update the ECS task definitions to reference all secrets. You may need to manually update the task definitions via AWS Console or update the Terraform code to include all secret references.

### Update Backend Task Definition

Add all required secrets to the backend task definition in `terraform/modules/ecs/main.tf`:

```hcl
secrets = [
  {
    name      = "JWT_SECRET"
    valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${var.project_name}-${var.environment}-jwt-secret"
  },
  {
    name      = "MONGO_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${var.project_name}-${var.environment}-docdb-password"
  },
  # Add more secrets as needed
]
```

Then run `terraform apply` again.

## Step 9: Verify Deployment

### Check ECS Services

```bash
# List ECS clusters
aws ecs list-clusters

# List services
aws ecs list-services --cluster coursebundler-prod-cluster

# Check service status
aws ecs describe-services \
  --cluster coursebundler-prod-cluster \
  --services coursebundler-prod-backend-service
```

### Check ALB

```bash
# Get ALB DNS name from Terraform output
terraform output alb_dns_name

# Test ALB endpoint
curl http://YOUR-ALB-DNS-NAME
```

### Check CloudFront

```bash
# Get CloudFront domain from Terraform output
terraform output cloudfront_domain

# Test CloudFront endpoint
curl https://YOUR-CLOUDFRONT-DOMAIN.cloudfront.net
```

## Step 10: Configure DNS (Optional)

If you have a custom domain:

1. Create a Route 53 hosted zone (or use existing)
2. Create an A record (Alias) pointing to CloudFront distribution
3. Update your domain's nameservers if needed

## Step 11: Update Application Configuration

### Update Frontend API URL

The frontend needs to know the backend API URL. Update `frontend/src/redux/store.js`:

```javascript
export const server = 'https://YOUR-ALB-DNS-NAME/api/v1';
// Or use CloudFront domain if configured
export const server = 'https://YOUR-CLOUDFRONT-DOMAIN/api/v1';
```

Rebuild and push the frontend image:

```bash
cd frontend
docker build -t coursebundler-frontend:latest .
docker tag coursebundler-frontend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-frontend-prod:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/coursebundler-frontend-prod:latest
```

Force new deployment in ECS:

```bash
aws ecs update-service \
  --cluster coursebundler-prod-cluster \
  --service coursebundler-prod-frontend-service \
  --force-new-deployment
```

## Monitoring and Troubleshooting

### View CloudWatch Logs

```bash
# Backend logs
aws logs tail /ecs/coursebundler-prod-backend --follow

# Frontend logs
aws logs tail /ecs/coursebundler-prod-frontend --follow
```

### Check Auto Scaling

```bash
# Describe auto scaling targets
aws application-autoscaling describe-scalable-targets \
  --service-namespace ecs
```

### View CloudWatch Alarms

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix coursebundler-prod
```

### Common Issues

1. **ECS Tasks Not Starting**
   - Check CloudWatch logs
   - Verify security groups allow traffic
   - Check task definition and image URI

2. **ALB Health Checks Failing**
   - Verify health check path is correct
   - Check security groups
   - Verify containers are listening on correct ports

3. **Database Connection Issues**
   - Verify DocumentDB security group allows backend traffic
   - Check database endpoint and credentials
   - Verify VPC configuration

4. **Auto Scaling Not Working**
   - Check CloudWatch metrics
   - Verify auto scaling policies are attached
   - Check service desired count

## Cost Optimization Tips

1. **Use Fargate Spot** for non-critical workloads (add to task definition)
2. **Scale down during off-hours** using scheduled scaling
3. **Enable S3 lifecycle policies** to archive old data
4. **Use CloudFront caching** to reduce origin requests
5. **Monitor and adjust** instance sizes based on actual usage

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**Warning**: This will delete all resources including databases. Make sure you have backups!

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [DocumentDB Best Practices](https://docs.aws.amazon.com/documentdb/latest/developerguide/best-practices.html)

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review Terraform state: `terraform show`
3. Check AWS Service Health Dashboard
4. Review design document for architecture details

---

**Last Updated**: 2024  
**Version**: 1.0

