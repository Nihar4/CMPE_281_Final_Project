variable "backend_ecs_service_name" {
  description = "Backend ECS service name"
  type        = string
}

variable "frontend_ecs_service_name" {
  description = "Frontend ECS service name"
  type        = string
}

variable "backend_cluster_name" {
  description = "Backend ECS cluster name"
  type        = string
}

variable "frontend_cluster_name" {
  description = "Frontend ECS cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "backend_min_capacity" {
  description = "Minimum backend tasks"
  type        = number
  default     = 2
}

variable "backend_max_capacity" {
  description = "Maximum backend tasks"
  type        = number
  default     = 10
}

variable "frontend_min_capacity" {
  description = "Minimum frontend tasks"
  type        = number
  default     = 2
}

variable "frontend_max_capacity" {
  description = "Maximum frontend tasks"
  type        = number
  default     = 10
}

