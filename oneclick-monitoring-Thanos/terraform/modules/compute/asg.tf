resource "aws_autoscaling_group" "k3s_workers" {
  name = "monitoring-asg"

  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.grafana_tg_arn,
    var.thanos_tg_arn
  ]

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.k3s_worker_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}
