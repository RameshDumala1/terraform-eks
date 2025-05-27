variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for EKS cluster"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  default = 1
}

variable "node_max_size" {
  default = 2
}

variable "node_desired_size" {
  default = 1
}

variable "node_disk_size" {
  default = 20
}

variable "iam_user_name" {
  default = "eks-admin-user"
}
