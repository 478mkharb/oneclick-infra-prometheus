################################
# ALB
################################
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

################################
# Grafana Target Group
################################
resource "aws_lb_target_group" "grafana" {
  name        = "grafana-tg"
  port        = 32000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    port                = "32000"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

################################
# Prometheus Target Group
################################
resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/-/ready"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

################################
# Listeners
################################
resource "aws_lb_listener" "http_grafana" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_listener" "http_prometheus" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}
