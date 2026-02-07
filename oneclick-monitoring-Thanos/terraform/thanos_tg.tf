resource "aws_lb_target_group" "thanos" {
  name        = "thanos-query-tg"
  port        = 30900
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = "30900"
    path     = "/"
    matcher  = "200-399"
    interval = 30
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
