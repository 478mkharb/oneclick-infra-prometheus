variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "oneclick-monitoring"
}

variable "instance_type_monitoring" {
  description = "EC2 instance type for monitoring ASG"
  type        = string
  default     = "t3.small"
}

variable "role" {
  description = "Role tag for the instances"
  type        = string
}
