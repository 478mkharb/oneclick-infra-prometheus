resource "aws_security_group" "alb_sg" {
  name        = "monitoring-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  # Grafana (via ALB)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus (via ALB :9090)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "monitoring-alb-sg"
    Project = var.project
  }
}
resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Security group for monitoring EC2 instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "private-ec2-sg"
    Project = var.project
  }
}
resource "aws_security_group_rule" "alb_to_grafana" {
  type                     = "ingress"
  from_port                = 32000
  to_port                  = 32000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_security_group_rule" "alb_to_prometheus" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_security_group_rule" "node_exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}
resource "aws_security_group_rule" "dns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

resource "aws_security_group_rule" "dns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}
