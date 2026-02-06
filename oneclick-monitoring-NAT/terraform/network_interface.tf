resource "aws_network_interface" "k3s_server_eni" {
  subnet_id       = aws_subnet.private_a.id
  private_ips     = ["10.0.1.10"]   # choose a free IP
  security_groups = [aws_security_group.private_ec2_sg.id]

  tags = {
    Name    = "k3s-server-eni"
    Project = var.project
  }
}
