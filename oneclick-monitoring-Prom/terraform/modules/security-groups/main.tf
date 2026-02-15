resource "aws_security_group" "alb_sg" {
  name        = "monitoring-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  # Public HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB to targets (egress only)
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
  description = "Security group for private k3s EC2 instances"
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
resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Security group for monitoring EC2 instances"
  vpc_id      = var.vpc_id

  # Grafana from ALB
  ingress {
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  # Prometheus from ALB
  ingress {
    from_port                = 9090
    to_port                  = 9090
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  # Node exporter (internal)
  ingress {
    from_port                = 9100
    to_port                  = 9100
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  # DNS (internal)
  ingress {
    from_port                = 53
    to_port                  = 53
    protocol                 = "udp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  ingress {
    from_port                = 53
    to_port                  = 53
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  # Outbound
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
