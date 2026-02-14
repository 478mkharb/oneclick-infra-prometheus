variable "region" {
  default = "ap-south-1"
  type    = string
}

variable "project" {
  default = "oneclick-monitoring"
  type = string
}

variable "instance_type_monitoring" {
  default = "t3.small"
  type = string
}

variable "role" {
  description = "Role tag for the instances"
  type        = string
}


