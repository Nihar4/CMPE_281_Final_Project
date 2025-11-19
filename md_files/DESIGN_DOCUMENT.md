# CourseBundler - AWS Infrastructure Design Document

## Executive Summary

CourseBundler is an online learning platform deployed on AWS with a resilient, performant, and scalable architecture. This document outlines the infrastructure design, architectural decisions, and deployment strategy.

---

## Table of Contents

1. [Design Choices](#design-choices)
2. [Infrastructure Diagram](#infrastructure-diagram)
3. [Sequence Diagrams](#sequence-diagrams)
4. [Single Points of Failure & Solutions](#single-points-of-failure--solutions)
5. [AWS Services Used](#aws-services-used)

---

## Design Choices

### **1. Containerization with Docker**
- **Choice**: Docker containers for both frontend and backend
- **Rationale**: 
  - Consistent deployment across environments
  - Easy scaling with ECS
  - Simplified CI/CD pipeline
  - Isolation of dependencies

### **2. Amazon ECS with Fargate**
- **Choice**: ECS Fargate over EC2 instances
- **Rationale**:
  - Serverless container management (no EC2 to manage)
  - Automatic scaling based on CPU/memory
  - Pay only for running containers
  - Built-in load balancing integration

### **3. Application Load Balancer (ALB)**
- **Choice**: ALB for traffic distribution
- **Rationale**:
  - Health checks and automatic failover
  - SSL/TLS termination
  - Path-based routing (frontend/backend)
  - Integration with Auto Scaling

### **4. Amazon RDS with Multi-AZ**
- **Choice**: RDS MongoDB-compatible (DocumentDB) or self-hosted MongoDB in ECS
- **Rationale**:
  - Automated backups
  - Multi-AZ for high availability
  - Automatic failover (< 60 seconds)
  - Point-in-time recovery

### **5. Amazon S3 + CloudFront**
- **Choice**: S3 for static assets, CloudFront for CDN
- **Rationale**:
  - Global content delivery
  - Reduced latency
  - Cost-effective storage
  - DDoS protection

### **6. Auto Scaling Groups**
- **Choice**: ECS Service Auto Scaling
- **Rationale**:
  - Scale based on CPU, memory, or custom metrics
  - Handle traffic bursts automatically
  - Cost optimization (scale down during low traffic)

### **7. CloudWatch Monitoring**
- **Choice**: CloudWatch for logging and monitoring
- **Rationale**:
  - Centralized logging
  - Custom metrics and alarms
  - Automatic recovery triggers
  - Performance insights

### **8. VPC with Multiple Availability Zones**
- **Choice**: VPC spanning 3 AZs
- **Rationale**:
  - High availability
  - Failure isolation
  - Network segmentation
  - Security groups for access control

### **9. Amazon ECR**
- **Choice**: ECR for Docker image storage
- **Rationale**:
  - Secure, scalable Docker registry
  - Integration with ECS
  - Image versioning
  - Access control via IAM

### **10. Secrets Management**
- **Choice**: AWS Secrets Manager or Parameter Store
- **Rationale**:
  - Secure storage of API keys, passwords
  - Automatic rotation
  - IAM-based access control
  - Audit logging

---

## Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Route 53 DNS  │
                    └────────┬───────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  CloudFront    │
                    │    (CDN)       │
                    └────────┬───────┘
                             │
                             ▼
        ┌──────────────────────────────────────────────┐
        │         Application Load Balancer (ALB)      │
        │         (Multi-AZ, Health Checks)             │
        └────────┬───────────────────────┬─────────────┘
                 │                       │
                 ▼                       ▼
        ┌─────────────────┐     ┌─────────────────┐
        │  Frontend ECS   │     │  Backend ECS    │
        │  Service        │     │  Service        │
        │  (Fargate)      │     │  (Fargate)      │
        └────────┬────────┘     └────────┬────────┘
                 │                       │
        ┌────────┴────────┐     ┌────────┴────────┐
        │  Auto Scaling   │     │  Auto Scaling   │
        │  (2-10 tasks)  │     │  (2-10 tasks)   │
        └────────────────┘     └────────────────┘
                 │                       │
                 │                       ▼
                 │              ┌─────────────────┐
                 │              │  DocumentDB      │
                 │              │  (Multi-AZ)      │
                 │              │  Primary +       │
                 │              │  Standby         │
                 │              └─────────────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  S3 Bucket      │
        │  (Static Assets)│
        └─────────────────┘

        ┌──────────────────────────────────────────────┐
        │              VPC (10.0.0.0/16)              │
        │  ┌──────────────┐  ┌──────────────┐        │
        │  │   AZ-1a      │  │   AZ-1b      │        │
        │  │  Public Sub  │  │  Public Sub  │        │
        │  │  Private Sub │  │  Private Sub │        │
        │  └──────────────┘  └──────────────┘        │
        │                                              │
        │  ┌──────────────────────────────────────┐  │
        │  │  NAT Gateway (Multi-AZ)               │  │
        │  │  Internet Gateway                     │  │
        │  └──────────────────────────────────────┘  │
        └──────────────────────────────────────────────┘

        ┌──────────────────────────────────────────────┐
        │         CloudWatch (Monitoring & Logs)        │
        │  - Application Logs                          │
        │  - Custom Metrics                            │
        │  - Alarms & Auto Recovery                    │
        └──────────────────────────────────────────────┘

        ┌──────────────────────────────────────────────┐
        │         AWS Secrets Manager                  │
        │  - Database Credentials                      │
        │  - API Keys (Razorpay, Cloudinary)          │
        │  - JWT Secrets                               │
        └──────────────────────────────────────────────┘
```

---

## Sequence Diagrams

### **Sequence Diagram 1: User Registration Flow**

```
User          CloudFront      ALB         Frontend ECS    Backend ECS    DocumentDB    Secrets Manager
  │               │            │              │               │              │               │
  │───POST /register──────────>│              │               │              │               │
  │               │            │              │               │              │               │
  │               │            │─────────────>│               │              │               │
  │               │            │              │               │              │               │
  │               │            │              │───POST /api/v1/register─────>│              │
  │               │            │              │               │              │               │
  │               │            │              │               │───Get Secrets───────────────>│
  │               │            │              │               │<───Secrets────────────────────│
  │               │            │              │               │              │               │
  │               │            │              │               │───Create User───────────────>│
  │               │            │              │               │              │               │
  │               │            │              │               │<───User Created──────────────│
  │               │            │              │               │              │               │
  │               │            │              │<───Success Response──────────│              │
  │               │            │<─────────────│               │              │               │
  │<──────────────┴────────────┴──────────────│               │              │               │
  │               │            │              │               │              │               │
```

### **Sequence Diagram 2: Course Creation (Admin) Flow**

```
Admin         ALB         Frontend ECS    Backend ECS    DocumentDB    S3          CloudWatch
  │            │              │               │              │           │              │
  │───POST /admin/createcourse──────────────>│               │           │              │
  │            │              │               │              │           │              │
  │            │              │───POST /api/v1/createcourse────────────>│              │
  │            │              │               │              │           │              │
  │            │              │               │───Auth Check─────────────>│              │
  │            │              │               │<───Authorized─────────────│              │
  │            │              │               │              │           │              │
  │            │              │               │───Upload Poster─────────>│              │
  │            │              │               │              │           │              │
  │            │              │               │<───S3 URL──────────────────│              │
  │            │              │               │              │           │              │
  │            │              │               │───Create Course──────────>│              │
  │            │              │               │              │           │              │
  │            │              │               │              │───Log Event───────────────>│
  │            │              │               │              │           │              │
  │            │              │               │<───Course Created──────────│              │
  │            │              │<───Success Response───────────│              │           │              │
  │<───────────┴──────────────┴───────────────│              │           │              │
  │            │              │               │              │           │              │
```

### **Sequence Diagram 3: Auto-Scaling on Traffic Burst**

```
Traffic      ALB         CloudWatch    ECS Service    Auto Scaling    New Tasks
  │           │              │              │              │              │
  │───High Traffic──────────>│              │              │              │
  │           │              │              │              │              │
  │           │───CPU > 70%──>│              │              │              │
  │           │              │              │              │              │
  │           │              │───Trigger Alarm─────────────>│              │
  │           │              │              │              │              │
  │           │              │              │───Scale Up (2→5 tasks)──────>│
  │           │              │              │              │              │
  │           │              │              │              │───Launch Tasks─────────>│
  │           │              │              │              │              │
  │           │              │              │<───Tasks Running─────────────│
  │           │              │              │              │              │
  │           │<───Distribute Traffic──────────────────────────────────────│
  │           │              │              │              │              │
  │           │              │───CPU < 30%───│              │              │
  │           │              │              │              │              │
  │           │              │              │───Scale Down (5→2 tasks)────>│
  │           │              │              │              │              │
```

---

## Single Points of Failure & Solutions

### **1. Single Database Instance**
- **Problem**: If the database fails, entire application is down
- **Solution**: 
  - Use DocumentDB Multi-AZ deployment
  - Automatic failover to standby replica (< 60 seconds)
  - Automated backups with point-in-time recovery
  - Read replicas for read scaling

### **2. Single Application Server**
- **Problem**: If one server fails, all traffic is lost
- **Solution**:
  - ECS Service with multiple tasks across multiple AZs
  - Auto Scaling Group (minimum 2 tasks)
  - ALB health checks automatically route traffic away from unhealthy tasks
  - Container auto-restart on failure

### **3. Single Availability Zone**
- **Problem**: If entire AZ fails, application is unavailable
- **Solution**:
  - Deploy resources across 3 Availability Zones
  - ALB spans multiple AZs
  - DocumentDB Multi-AZ with automatic failover
  - NAT Gateway in each AZ for redundancy

### **4. Single Load Balancer**
- **Problem**: If ALB fails, no traffic routing
- **Solution**:
  - ALB is inherently multi-AZ (AWS managed service)
  - Route 53 health checks with failover to backup region
  - CloudFront provides additional layer of redundancy

### **5. Single Point of Storage (S3 Bucket)**
- **Problem**: If S3 bucket fails or is deleted, static assets lost
- **Solution**:
  - S3 versioning enabled
  - Cross-region replication for disaster recovery
  - CloudFront caching reduces dependency on S3
  - Automated backups to separate S3 bucket

### **Additional Resilience Measures:**
- **Secrets Management**: AWS Secrets Manager with automatic rotation
- **Monitoring**: CloudWatch alarms trigger auto-recovery actions
- **Network**: VPC with redundant NAT Gateways
- **Container Health**: ECS health checks restart unhealthy containers
- **Database**: Automated daily backups with 7-day retention

---

## AWS Services Used

### **Compute & Containers**
- **Amazon ECS (Fargate)**: Container orchestration
- **Amazon ECR**: Docker image registry
- **Auto Scaling**: Automatic scaling based on metrics

### **Networking**
- **VPC**: Isolated network environment
- **Application Load Balancer (ALB)**: Traffic distribution
- **Route 53**: DNS management
- **CloudFront**: CDN for global content delivery
- **NAT Gateway**: Outbound internet access for private subnets
- **Internet Gateway**: Public internet access

### **Database**
- **Amazon DocumentDB**: MongoDB-compatible managed database
- **Multi-AZ Deployment**: High availability
- **Automated Backups**: Point-in-time recovery

### **Storage**
- **Amazon S3**: Static asset storage
- **S3 Versioning**: Data protection
- **CloudFront**: CDN caching

### **Monitoring & Logging**
- **CloudWatch**: Logs, metrics, alarms
- **CloudWatch Alarms**: Auto-recovery triggers
- **CloudWatch Logs**: Centralized logging

### **Security**
- **AWS Secrets Manager**: Secure credential storage
- **IAM**: Access control
- **Security Groups**: Network-level firewall
- **VPC**: Network isolation

### **Cost Optimization**
- **Auto Scaling**: Scale down during low traffic
- **Fargate Spot**: Optional for cost savings
- **S3 Lifecycle Policies**: Archive old data
- **CloudFront**: Reduce origin requests

---

## Performance Optimizations

1. **CloudFront CDN**: Cache static assets globally
2. **Auto Scaling**: Handle traffic bursts automatically
3. **Database Read Replicas**: Distribute read load
4. **Connection Pooling**: Efficient database connections
5. **ALB Health Checks**: Fast failover (< 30 seconds)
6. **Container Caching**: Docker layer caching in ECR
7. **S3 Transfer Acceleration**: Faster uploads

---

## Estimated Costs (Monthly)

- **ECS Fargate** (2-10 tasks): ~$50-200
- **ALB**: ~$20
- **DocumentDB** (Multi-AZ): ~$200-300
- **S3 + CloudFront**: ~$10-50
- **NAT Gateway**: ~$35
- **CloudWatch**: ~$10-20
- **Route 53**: ~$1
- **Total**: ~$326-606/month (varies with usage)

---

## Deployment Regions

- **Primary**: us-east-1 (N. Virginia)
- **Backup**: us-west-2 (Oregon) - for disaster recovery

---

## Next Steps

1. Review and approve design
2. Set up AWS account and IAM roles
3. Deploy infrastructure with Terraform
4. Build and push Docker images to ECR
5. Configure secrets in Secrets Manager
6. Deploy applications to ECS
7. Set up monitoring and alarms
8. Load testing and optimization

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Author**: CourseBundler DevOps Team

