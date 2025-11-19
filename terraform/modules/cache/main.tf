# Cache Module - ElastiCache Redis

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cache-subnet"
    }
  )
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-redis-params"
  family = "redis7"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-params"
    }
  )
}

# ElastiCache Replication Group (Single node for cost optimization)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-${var.environment}-redis"
  description                = "Redis cluster for ${var.project_name}"
  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1  # Single node for cost optimization
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [var.security_group_id]
  automatic_failover_enabled = false  # Disabled for single node (cost optimization)
  at_rest_encryption_enabled  = false  # Disabled for cost (can enable if needed)
  transit_encryption_enabled  = false  # Disabled for cost (can enable if needed)

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis"
    }
  )
}

