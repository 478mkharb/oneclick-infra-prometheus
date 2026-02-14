resource "aws_autoscaling_group" "monitoring_asg" {
  name = "monitoring-asg"

  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.grafana_tg_arn,
    var.prometheus_tg_arn
  ]

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.monitoring_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}
