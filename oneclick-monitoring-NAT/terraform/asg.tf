resource "aws_autoscaling_group" "k3s_workers" {
  name = "k3s-workers-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  
  target_group_arns = [
    aws_lb_target_group.grafana.arn,
    aws_lb_target_group.prometheus.arn
  ]

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.k3s_worker_lt.id
    version = "$Latest"
  }

  tag  {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}
  