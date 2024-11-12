# variables.tf
variable "vpc_id" {
  description = "The ID of the VPC where the ECS service will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "The ECS Cluster name"
  default     = "frontend-cluster"
}

variable "alb_target_group_arn" {
  description = "The ARN of the existing ALB target group"
  type        = string
}

variable "docker_image" {
  description = "Docker image for the ECS service frontend"
  type        = string
}

variable "desired_count" {
  description = "The desired number of ECS instances"
  default     = 2
  type        = number
}
