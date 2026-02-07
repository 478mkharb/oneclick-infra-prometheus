resource "aws_lb_target_group" "grafana" {
  name        = "grafana-tg"
  port        = 32000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = "32000"
    path     = "/"              
    matcher  = "200-399"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
