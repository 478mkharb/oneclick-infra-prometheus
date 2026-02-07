resource "aws_lb_listener" "http_grafana" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_listener_rule" "thanos" {
  listener_arn = aws_lb_listener.http_grafana.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.thanos.arn
  }

  condition {
    path_pattern {
      values = ["/thanos", "/thanos/*"]
    }
  }
}