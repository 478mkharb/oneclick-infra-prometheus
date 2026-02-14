resource "aws_lb" "monitoring" {
  name               = "monitoring-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name    = "monitoring-alb"
    Project = var.project
  }
}

resource "aws_lb_target_group" "grafana" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/grafana/api/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "grafana-tg"
  }
}

resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/-/ready"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "prometheus-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/prometheus/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  condition {
    path_pattern {
      values = ["/grafana/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = var.monitoring_instance_id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "prometheus" {
  target_group_arn = aws_lb_target_group.prometheus.arn
  target_id        = var.monitoring_instance_id
  port             = 9090
}