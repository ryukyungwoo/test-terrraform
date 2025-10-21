variable "project_name" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list(string)
  default = [ "ap-northeast-3a", "ap-northeast-3c" ]
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-3"
}