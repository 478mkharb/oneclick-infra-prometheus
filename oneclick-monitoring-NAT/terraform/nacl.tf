resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "private-nacl"
    Project = var.project
  }
}

resource "aws_network_acl_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_rule" "inbound_ephemeral_tcp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 85
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9100
  to_port        = 9100
}

resource "aws_network_acl_rule" "inbound_ephemeral_tcp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 90
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "inbound_ephemeral_udp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 95
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "inbound_grafana" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 30000
  to_port        = 30000
}

resource "aws_network_acl_rule" "inbound_prometheus" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 30090
  to_port        = 30090
}

resource "aws_network_acl_rule" "outbound_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 1200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
