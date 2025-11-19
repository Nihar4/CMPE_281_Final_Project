# Main Terraform Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Common tags as locals
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name      = var.project_name
  environment       = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  container_port    = var.container_port
  common_tags       = local.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

# Cache Module (ElastiCache Redis)
module "cache" {
  source = "./modules/cache"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.vpc.redis_security_group_id
  common_tags        = local.common_tags
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.vpc.alb_security_group_id
  container_port     = var.container_port
  target_group_vpc_id = module.vpc.vpc_id
  common_tags        = local.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  container_port        = var.container_port
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  desired_count         = var.desired_count
  min_capacity          = var.min_capacity
  max_capacity          = var.max_capacity
  ecr_repository_url    = module.ecr.repository_url
  ecr_repository_arn    = module.ecr.repository_arn
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.vpc.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  redis_endpoint        = module.cache.redis_endpoint
  common_tags          = local.common_tags
  
  depends_on = [
    module.vpc,
    module.ecr,
    module.alb,
    module.cache
  ]
}

# Storage Module (S3 + CloudFront)
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
  common_tags  = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name      = var.project_name
  environment       = var.environment
  alert_email       = var.alert_email
  ecs_cluster_name  = module.ecs.cluster_name
  ecs_service_name  = module.ecs.service_name
  alb_arn           = module.alb.alb_arn
  target_group_arn  = module.alb.target_group_arn
  common_tags       = local.common_tags
  
  depends_on = [
    module.ecs,
    module.alb
  ]
}
