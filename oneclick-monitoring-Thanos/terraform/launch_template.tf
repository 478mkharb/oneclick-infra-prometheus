resource "aws_launch_template" "k3s_worker_lt" {
  name_prefix   = "k3s-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile {
    name = "ec2-ssm-profile"
  }

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
set -ux
exec > /var/log/k3s-worker.log 2>&1

echo "[INFO] Starting k3s worker bootstrap"

apt-get update -y
apt-get install -y curl

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
curl -sfL https://get.k3s.io | \
  K3S_URL=https://10.0.3.10:6443 \
  K3S_TOKEN=k3s-static-token-2026 \
  K3S_NODE_IP=$PRIVATE_IP \
  sh -

systemctl enable k3s-agent
systemctl start k3s-agent
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "k3s_worker"
      Role    = var.role
      Project = var.project
    }
  }
}
