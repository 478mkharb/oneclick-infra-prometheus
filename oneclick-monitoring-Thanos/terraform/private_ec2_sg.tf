resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Security group for private k3s EC2 instances"
  vpc_id      = aws_vpc.this.id

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

# ALB → Grafana
resource "aws_security_group_rule" "alb_to_grafana" {
  type                     = "ingress"
  from_port                = 32000
  to_port                  = 32000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# ALB → Thanos Query (Prometheus HA UI)
resource "aws_security_group_rule" "alb_to_thanos" {
  type                     = "ingress"
  from_port                = 30900
  to_port                  = 30900
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# k3s API
resource "aws_security_group_rule" "k3s_api" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

# flannel VXLAN
resource "aws_security_group_rule" "flannel_vxlan" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

# k3s supervisor
resource "aws_security_group_rule" "k3s_supervisor" {
  type                     = "ingress"
  from_port                = 6444
  to_port                  = 6444
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

# kubelet
resource "aws_security_group_rule" "kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

# CoreDNS UDP
resource "aws_security_group_rule" "dns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

# CoreDNS TCP
resource "aws_security_group_rule" "dns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}
