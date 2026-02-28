############################################
# ALB Security Group
############################################
resource "aws_security_group" "alb_sg" {
  name        = "monitoring-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
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

############################################
# Private EC2 / ASG Security Group
############################################
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
# Grafana from ALB
resource "aws_security_group_rule" "alb_to_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Prometheus from ALB
resource "aws_security_group_rule" "alb_to_prometheus" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Nginx Prometheus Exporter (internal scrape)
resource "aws_security_group_rule" "nginx_exporter" {
  type              = "ingress"
  from_port         = 9113
  to_port           = 9113
  protocol          = "tcp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}

# Node Exporter (internal only)
resource "aws_security_group_rule" "node_exporter" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}
# Alertmanager (Prometheus → Alertmanager, internal only)
resource "aws_security_group_rule" "alertmanager_internal" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}
# Nginx Web App from ALB
resource "aws_security_group_rule" "alb_to_nginx" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}
