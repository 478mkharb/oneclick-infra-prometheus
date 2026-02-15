############################################
# Self-referencing rules (MUST be separate)
############################################

# Node Exporter (EC2 → EC2)
resource "aws_security_group_rule" "node_exporter_self" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}

# DNS UDP (EC2 → EC2)
resource "aws_security_group_rule" "dns_udp_self" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}

# DNS TCP (EC2 → EC2)
resource "aws_security_group_rule" "dns_tcp_self" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.private_ec2_sg.id
  self              = true
}
