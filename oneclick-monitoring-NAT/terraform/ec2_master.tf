resource "aws_instance" "k3s_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = aws_subnet.private_a.id

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

  iam_instance_profile = "ec2-ssm-profile"

  user_data = base64encode(<<EOF
#!/bin/bash
set -eux

exec > /var/log/k3s-server.log 2>&1

# basic packages
apt-get update -y
apt-get install -y curl iptables

# ensure forwarding
iptables -P FORWARD ACCEPT
sysctl -w net.ipv4.ip_forward=1

# install ssm agent
snap install amazon-ssm-agent --classic || true
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# install k3s server
curl -sfL https://get.k3s.io | sh -
systemctl enable k3s
systemctl start k3s

# wait for token
sleep 30
EOF
)

  tags = {
    Name    = "k3s_server"
    Role    = var.role
    Project = var.project
  }
}
