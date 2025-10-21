variable "project_name" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "vpc_id" {
    description = "VPC ID where security groups will be created"
    type        = string
}

variable "vpc_cidr" {
    description = "VPC CIDR block"
    type        = string
}

variable "cluster_name" {
    description = "EKS cluster name"
    type        = string
}