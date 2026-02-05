resource "aws_autoscaling_group" "monitoring_asg" {
  name = "monitoring-asg"

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.monitoring_lt.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.grafana_tg.arn,
    aws_lb_target_group.prometheus_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = var.role
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
