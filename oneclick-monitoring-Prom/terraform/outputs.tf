output "alb_dns" {
  value = module.alb.alb_dns
}
output "monitoring_asg_name" {
  value = module.compute.monitoring_asg_name
}
