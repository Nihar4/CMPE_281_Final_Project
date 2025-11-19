# AWS Services Used - CourseBundler Project

## Complete List of AWS Services

### 1. **Amazon ECS (Elastic Container Service)**

- **Service Type**: Container Orchestration
- **Usage**:
  - Hosts frontend and backend Docker containers
  - Uses Fargate launch type (serverless containers)
  - Manages container lifecycle and deployment
  - Provides high availability across multiple Availability Zones

### 2. **Amazon ECR (Elastic Container Registry)**

- **Service Type**: Container Registry
- **Usage**:
  - Stores Docker images for frontend and backend
  - Provides secure, scalable Docker image storage
  - Integrated with ECS for seamless deployments

### 3. **Amazon VPC (Virtual Private Cloud)**

- **Service Type**: Networking
- **Usage**:
  - Isolated network environment for all resources
  - Spans 3 Availability Zones for high availability
  - Provides network segmentation with public and private subnets

### 4. **Application Load Balancer (ALB)**

- **Service Type**: Load Balancing
- **Usage**:
  - Distributes incoming traffic across multiple ECS tasks
  - Performs health checks and automatic failover
  - Routes traffic based on path (frontend/backend)
  - Provides SSL/TLS termination

### 5. **Amazon CloudFront**

- **Service Type**: Content Delivery Network (CDN)
- **Usage**:
  - Global content delivery for improved performance
  - Caches static assets and API responses
  - Reduces latency and origin load
  - Provides DDoS protection

### 6. **Amazon DocumentDB**

- **Service Type**: Database
- **Usage**:
  - MongoDB-compatible managed database
  - Multi-AZ deployment for high availability
  - Automatic backups and point-in-time recovery
  - Stores application data (users, courses, payments)

### 7. **Amazon S3 (Simple Storage Service)**

- **Service Type**: Object Storage
- **Usage**:
  - Stores static assets (images, videos)
  - Versioning enabled for data protection
  - Lifecycle policies for cost optimization
  - Backup storage

### 8. **Amazon CloudWatch**

- **Service Type**: Monitoring & Logging
- **Usage**:
  - Centralized logging for ECS containers
  - Custom metrics and alarms
  - Auto-recovery triggers
  - Performance monitoring

### 9. **AWS Application Auto Scaling**

- **Service Type**: Auto Scaling
- **Usage**:
  - Automatically scales ECS services based on CPU and memory
  - Handles traffic bursts
  - Cost optimization through scale-down
  - Target tracking scaling policies

### 10. **AWS Secrets Manager**

- **Service Type**: Secrets Management
- **Usage**:
  - Securely stores database passwords
  - Stores JWT secrets
  - Stores API keys (Razorpay, Cloudinary)
  - Automatic secret rotation support

### 11. **Amazon Route 53**

- **Service Type**: DNS Service
- **Usage**:
  - Domain name resolution
  - Health checks and failover routing
  - Optional: Custom domain configuration

### 12. **NAT Gateway**

- **Service Type**: Networking
- **Usage**:
  - Provides outbound internet access for private subnets
  - One NAT Gateway per Availability Zone
  - Enables ECS tasks to pull images and access external APIs

### 13. **Internet Gateway**

- **Service Type**: Networking
- **Usage**:
  - Provides internet access for public subnets
  - Enables ALB and NAT Gateways to connect to internet

### 14. **AWS IAM (Identity and Access Management)**

- **Service Type**: Security & Access Control
- **Usage**:
  - Manages permissions for ECS tasks
  - IAM roles for ECS task execution
  - IAM roles for ECS tasks
  - Least privilege access policies

### 15. **AWS Security Groups**

- **Service Type**: Network Security
- **Usage**:
  - Firewall rules for network traffic
  - Controls inbound/outbound access
  - Separate security groups for ALB, ECS tasks, and DocumentDB

### 16. **AWS Certificate Manager (ACM)**

- **Service Type**: SSL/TLS Certificates
- **Usage**:
  - Manages SSL/TLS certificates for HTTPS
  - Certificate for ALB (in application region)
  - Certificate for CloudFront (in us-east-1)
  - Automatic certificate renewal

### 17. **AWS CloudWatch Logs**

- **Service Type**: Logging
- **Usage**:
  - Stores application logs from ECS containers
  - Log retention policies
  - Centralized log aggregation
  - Log query and analysis

### 18. **AWS CloudWatch Alarms**

- **Service Type**: Monitoring
- **Usage**:
  - Monitors CPU and memory utilization
  - Triggers on unhealthy tasks
  - Sends notifications
  - Integrates with auto-scaling

### 19. **AWS CloudWatch Metrics**

- **Service Type**: Monitoring
- **Usage**:
  - Tracks ECS service metrics
  - Custom application metrics
  - Performance insights
  - Historical data analysis

### 20. **AWS Subnets**

- **Service Type**: Networking
- **Usage**:
  - Public subnets for ALB and NAT Gateways
  - Private subnets for ECS tasks and DocumentDB
  - Network segmentation for security

### 21. **AWS Route Tables**

- **Service Type**: Networking
- **Usage**:
  - Routes traffic within VPC
  - Public route table (via Internet Gateway)
  - Private route tables (via NAT Gateways)

### 22. **Elastic IP Addresses**

- **Service Type**: Networking
- **Usage**:
  - Static IP addresses for NAT Gateways
  - Ensures consistent outbound IP addresses

---

## Service Categories Summary

### **Compute & Containers**

- Amazon ECS (Fargate)
- Amazon ECR

### **Networking & Content Delivery**

- Amazon VPC
- Application Load Balancer (ALB)
- Amazon CloudFront
- Amazon Route 53
- NAT Gateway
- Internet Gateway
- Subnets
- Route Tables
- Elastic IP Addresses

### **Database**

- Amazon DocumentDB

### **Storage**

- Amazon S3

### **Monitoring & Logging**

- Amazon CloudWatch
- CloudWatch Logs
- CloudWatch Metrics
- CloudWatch Alarms

### **Auto Scaling**

- AWS Application Auto Scaling

### **Security**

- AWS IAM
- AWS Security Groups
- AWS Secrets Manager
- AWS Certificate Manager (ACM)

---

## Total Count: 22 AWS Services

---

**Note**: This list includes all AWS services used in the Terraform infrastructure and application architecture. Some services (like VPC components) are part of the VPC service but listed separately for clarity.
