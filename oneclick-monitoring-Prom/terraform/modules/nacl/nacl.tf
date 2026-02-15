resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id

  tags = {
    Name    = "private-nacl"
    Project = var.project
  }
}

############################################
# Associate NACL with private subnets
############################################
resource "aws_network_acl_association" "private" {
  count = length(var.private_subnet_ids)

  subnet_id      = var.private_subnet_ids[count.index]
  network_acl_id = aws_network_acl.private_nacl.id
}

############################################
# INBOUND RULES
############################################

# Grafana (ALB → EC2)
resource "aws_network_acl_rule" "inbound_grafana" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 80
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 3000
  to_port        = 3000
}

# Prometheus (ALB → EC2)
resource "aws_network_acl_rule" "inbound_prometheus" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 85
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 9090
  to_port        = 9090
}

# Node Exporter (internal)
resource "aws_network_acl_rule" "inbound_node_exporter" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 90
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 9100
  to_port        = 9100
}

# Ephemeral TCP (responses, health checks)
resource "aws_network_acl_rule" "inbound_ephemeral_tcp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Ephemeral UDP (DNS, system traffic)
resource "aws_network_acl_rule" "inbound_ephemeral_udp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

############################################
# OUTBOUND RULES (REQUIRED – NACL is stateless)
############################################

resource "aws_network_acl_rule" "outbound_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
