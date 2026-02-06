
resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 32090
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = "32090"
    path     = "/"
    matcher  = "200-399"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "prometheus_workers" {
  for_each = toset(var.worker_instance_ids)

  target_group_arn = aws_lb_target_group.prometheus.arn
  target_id        = each.value
  port             = 32090
}
