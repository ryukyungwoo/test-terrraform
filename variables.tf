variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hello-pet"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "test"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-3"
}