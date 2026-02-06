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
  from_port                = 32090
  to_port                  = 32090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "k3s_api" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

resource "aws_security_group_rule" "flannel_vxlan" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.private_ec2_sg.id
}

