resource "aws_lb_target_group" "grafana" {
  name        = "grafana-tg"
  port        = 32000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = "32000"
    path     = "/login"
    matcher  = "200-399"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "grafana_workers" {
  for_each = toset(var.worker_instance_ids)

  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = each.value
  port             = 32000
}
