variable "project" {
  default = "oneclick-monitoring"
}
variable "role" {
  description = "Role tag for the instances"
  type        = string
}
variable "instance_type_monitoring" {
  description = "Instance type for monitoring instances"
  type        = string
  default     = "t3.small"
}
variable "private_subnet_ids" {
  type = list(string)
}

variable "private_ec2_sg_id" {
  type = string
}

variable "grafana_tg_arn" {
  type = string
}
variable "thanos_tg_arn" {
  type = string
}

variable "k3s_token" {
  sensitive = true
}
variable "k3s_server_private_ip" {
  type = string
}