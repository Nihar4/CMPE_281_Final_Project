# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/${var.environment}/application"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-application-logs"
  }
}

# CloudWatch Alarm for High CPU Utilization (Backend)
resource "aws_cloudwatch_metric_alarm" "backend_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-backend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors backend ECS CPU utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-high-cpu-alarm"
  }
}

# CloudWatch Alarm for High Memory Utilization (Backend)
resource "aws_cloudwatch_metric_alarm" "backend_high_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-backend-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors backend ECS memory utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-high-memory-alarm"
  }
}

# CloudWatch Alarm for Unhealthy Tasks (Backend)
resource "aws_cloudwatch_metric_alarm" "backend_unhealthy_tasks" {
  alarm_name          = "${var.project_name}-${var.environment}-backend-unhealthy-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "This metric monitors backend ECS unhealthy tasks"
  treat_missing_data  = "breaching"

  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-unhealthy-tasks-alarm"
  }
}

# CloudWatch Alarm for High CPU Utilization (Frontend)
resource "aws_cloudwatch_metric_alarm" "frontend_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-frontend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors frontend ECS CPU utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.frontend_service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-frontend-high-cpu-alarm"
  }
}

# Outputs
output "log_group_name" {
  value = aws_cloudwatch_log_group.application.name
}

