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
set -ux
exec > /var/log/k3s-server.log 2>&1

echo "[BOOT] Waiting for network"
for i in {1..30}; do
  ping -c1 8.8.8.8 && break
  sleep 10
done

echo "[BOOT] Updating system"
apt-get update -y
apt-get install -y curl iptables ca-certificates

echo "[BOOT] Enable forwarding"
iptables -P FORWARD ACCEPT || true
sysctl -w net.ipv4.ip_forward=1 || true

echo "[SSM] Installing SSM Agent"

# Try snap (Ubuntu default)
if command -v snap >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic || true
fi

# Fallback to deb if snap service not present
if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
  curl -fsSL -o /tmp/amazon-ssm-agent.deb \
    https://s3.ap-south-1.amazonaws.com/amazon-ssm-ap-south-1/latest/debian_amd64/amazon-ssm-agent.deb
  dpkg -i /tmp/amazon-ssm-agent.deb || apt-get -f install -y
fi

systemctl enable amazon-ssm-agent || true
systemctl restart amazon-ssm-agent || true

echo "[K3S] Installing k3s server"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

echo "[K3S] Waiting for kubeconfig"
for i in {1..30}; do
  [ -f /etc/rancher/k3s/k3s.yaml ] && break
  sleep 10
done

echo "[BOOT] k3s server bootstrap complete"
EOF
)

  tags = {
    Name    = "k3s_server"
    Role    = "k3s_server"
    Project = var.project
  }
}
