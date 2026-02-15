############################################
# ALB Security Group
############################################
resource "aws_security_group" "alb_sg" {
  name        = "monitoring-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  # Public HTTP access to ALB
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB -> EC2 targets
  egress {
    description = "Allow outbound to targets"
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

############################################
# Private EC2 / ASG Security Group
############################################
resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Security group for monitoring EC2 instances"
  vpc_id      = var.vpc_id

  # Grafana from ALB
  ingress {
    description             = "Grafana from ALB"
    from_port               = 3000
    to_port                 = 3000
    protocol                = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  # Prometheus from ALB
  ingress {
    description             = "Prometheus from ALB"
    from_port               = 9090
    to_port                 = 9090
    protocol                = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  # Node Exporter (internal only)
  ingress {
    description             = "Node exporter internal"
    from_port               = 9100
    to_port                 = 9100
    protocol                = "tcp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  # DNS (internal)
  ingress {
    description             = "DNS UDP internal"
    from_port               = 53
    to_port                 = 53
    protocol                = "udp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  ingress {
    description             = "DNS TCP internal"
    from_port               = 53
    to_port                 = 53
    protocol                = "tcp"
    source_security_group_id = aws_security_group.private_ec2_sg.id
  }

  # Outbound access (SSM, apt, yum, etc.)
  egress {
    description = "Allow all outbound"
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
