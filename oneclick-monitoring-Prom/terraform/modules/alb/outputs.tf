output "grafana_tg_arn" {
  value = aws_lb_target_group.grafana.arn
}

output "prometheus_tg_arn" {
  value = aws_lb_target_group.prometheus.arn
}

output "alb_dns" {
  value = aws_lb.monitoring.dns_name
}
output "nginx_tg_arn" {
  value = aws_lb_target_group.nginx_web.arn
  
}