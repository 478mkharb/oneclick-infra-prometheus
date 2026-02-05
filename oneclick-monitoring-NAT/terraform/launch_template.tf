resource "aws_launch_template" "monitoring_lt" {
  name_prefix   = "lt-${var.project}-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_monitoring

  iam_instance_profile {
    name = "ec2-ssm-profile"
  }

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
set -eux

# ===============================
# LOG EVERYTHING
# ===============================
exec > /var/log/user-data.log 2>&1

echo "[BOOT] User-data started"

# ===============================
# WAIT FOR NETWORK (CRITICAL)
# ===============================
echo "[BOOT] Waiting for network & DNS"
for i in {1..30}; do
  ping -c1 8.8.8.8 && break
  sleep 10
done

# ===============================
# UPDATE SYSTEM
# ===============================
apt-get update -y

# ===============================
# INSTALL SSM AGENT (UBUNTU SAFE)
# ===============================
echo "[SSM] Installing SSM Agent"

# Try SNAP first (Ubuntu default)
if command -v snap >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic || true
fi

# Fallback to DEB (guaranteed)
if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
  curl -fsSL -o /tmp/amazon-ssm-agent.deb \
    https://s3.ap-south-1.amazonaws.com/amazon-ssm-ap-south-1/latest/debian_amd64/amazon-ssm-agent.deb
  dpkg -i /tmp/amazon-ssm-agent.deb || apt-get -f install -y
fi

# ===============================
# FORCE-ENABLE + HARD RESTART LOOP
# ===============================
echo "[SSM] Enabling and restarting agent"

systemctl enable amazon-ssm-agent || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent || true

for i in {1..10}; do
  systemctl restart amazon-ssm-agent || true
  systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent || true
  sleep 30
done

# ===============================
# STATUS CHECK
# ===============================
systemctl status amazon-ssm-agent --no-pager || true
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent --no-pager || true

echo "[SSM] Agent setup complete"
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "monitoring-instance"
      Role    = var.role
      Project = var.project
    }
  }
}
