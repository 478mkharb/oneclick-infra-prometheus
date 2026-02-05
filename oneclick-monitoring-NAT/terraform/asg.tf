resource "aws_autoscaling_group" "k3s_workers" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.k3s_worker_lt.id
    version = "$Latest"
  }

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
}
