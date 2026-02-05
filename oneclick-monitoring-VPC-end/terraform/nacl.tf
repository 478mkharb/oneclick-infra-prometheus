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

# Inbound: ALB -> Grafana
resource "aws_network_acl_rule" "inbound_grafana" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 32000
  to_port        = 32000
}

# Inbound: ALB -> Prometheus
resource "aws_network_acl_rule" "inbound_prometheus" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 32090
  to_port        = 32090
}

# Inbound: return traffic (SSM, ALB responses)
resource "aws_network_acl_rule" "inbound_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Outbound: HTTPS to SSM endpoints
resource "aws_network_acl_rule" "outbound_https" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 443
  to_port        = 443
}

# Outbound: ephemeral responses
resource "aws_network_acl_rule" "outbound_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
  from_port      = 1024
  to_port        = 65535
}
