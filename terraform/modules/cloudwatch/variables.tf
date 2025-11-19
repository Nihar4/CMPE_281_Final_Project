variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "backend_service_name" {
  description = "Backend ECS service name"
  type        = string
  default     = ""
}

variable "frontend_service_name" {
  description = "Frontend ECS service name"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = ""
}

