variable "region" {
  default = "ap-south-1"
}

variable "project" {
  default = "oneclick-monitoring"
}

variable "instance_type_monitoring" {
  default = "t3.small"
}

variable "role" {
  description = "Role tag for the instances"
  type        = string
}
variable "k3s_server_private_ip" {
  type        = string
  description = "Static private IP for k3s server ENI"
}

variable "k3s_token" {
  type        = string
  sensitive   = true
}
