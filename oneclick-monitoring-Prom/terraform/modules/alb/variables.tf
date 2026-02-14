variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}
variable "monitoring_instance_id" {
  description = "EC2 instance ID where Grafana and Prometheus are running"
  type        = string
  
}