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

echo "[BOOT] Starting k3s server bootstrap"

# -----------------------------
# System prep
# -----------------------------
apt-get update -y
apt-get install -y curl iptables ca-certificates

iptables -P FORWARD ACCEPT
sysctl -w net.ipv4.ip_forward=1

# -----------------------------
# Install SSM Agent (DEB - stable)
# -----------------------------
if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
  curl -fsSL -o /tmp/amazon-ssm-agent.deb \
    https://s3.ap-south-1.amazonaws.com/amazon-ssm-ap-south-1/latest/debian_amd64/amazon-ssm-agent.deb
  dpkg -i /tmp/amazon-ssm-agent.deb || apt-get -f install -y
fi

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# -----------------------------
# Install k3s SERVER
# -----------------------------
curl -sfL https://get.k3s.io | sh -

systemctl enable k3s
systemctl restart k3s

# -----------------------------
# Wait for kubeconfig
# -----------------------------
echo "[BOOT] Waiting for k3s kubeconfig..."
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 5
done

chmod 644 /etc/rancher/k3s/k3s.yaml

# -----------------------------
# Wait for node-token
# -----------------------------
echo "[BOOT] Waiting for k3s node-token..."
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 5
done

echo "[BOOT] k3s server is ready"
EOF
)

  tags = {
    Name    = "k3s_server"
    Role    = "k3s_server"
    Project = var.project
  }
}
