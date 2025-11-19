# Terraform Outputs

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "cloudfront_url" {
  description = "CloudFront distribution URL for frontend"
  value       = "https://${module.storage.cloudfront_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.storage.cloudfront_distribution_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for Docker images"
  value       = module.ecr.repository_url
}

output "redis_endpoint" {
  description = "Redis ElastiCache endpoint"
  value       = module.cache.redis_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend"
  value       = module.storage.bucket_name
}
