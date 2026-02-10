output "grafana_tg_arn" {
  value = aws_lb_target_group.grafana.arn
}

output "thanos_tg_arn" {
  value = aws_lb_target_group.thanos.arn
}
