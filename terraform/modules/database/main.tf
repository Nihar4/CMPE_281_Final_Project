# DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-docdb-subnet-group"
  }
}

# DocumentDB Cluster Parameter Group
resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb5.0"
  name        = "${var.project_name}-${var.environment}-docdb-params"
  description = "DocumentDB cluster parameter group"

  tags = {
    Name = "${var.project_name}-${var.environment}-docdb-params"
  }
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${var.project_name}-${var.environment}-docdb-cluster"
  engine                          = "docdb"
  engine_version                  = "5.0.0"
  master_username                 = "admin"
  master_password                 = random_password.db_password.result
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  vpc_security_group_ids          = [var.security_group_id]
  storage_encrypted               = true
  backup_retention_period         = 7
  preferred_backup_window         = "03:00-04:00"
  preferred_maintenance_window    = "mon:04:00-mon:05:00"
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  skip_final_snapshot             = false
  final_snapshot_identifier        = "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name = "${var.project_name}-${var.environment}-docdb-cluster"
  }
}

# DocumentDB Cluster Instances
resource "aws_docdb_cluster_instance" "main" {
  count              = var.db_instance_count
  identifier         = "${var.project_name}-${var.environment}-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.db_instance_class

  tags = {
    Name = "${var.project_name}-${var.environment}-docdb-instance-${count.index + 1}"
  }
}

# Random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-${var.environment}-docdb-password"

  tags = {
    Name = "${var.project_name}-${var.environment}-docdb-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Outputs
output "endpoint" {
  value       = aws_docdb_cluster.main.endpoint
  description = "DocumentDB cluster endpoint"
}

output "port" {
  value       = aws_docdb_cluster.main.port
  description = "DocumentDB cluster port"
}

output "reader_endpoint" {
  value       = aws_docdb_cluster.main.reader_endpoint
  description = "DocumentDB cluster reader endpoint"
}

output "password_secret_arn" {
  value       = aws_secretsmanager_secret.db_password.arn
  description = "ARN of the secret storing the database password"
  sensitive   = true
}

