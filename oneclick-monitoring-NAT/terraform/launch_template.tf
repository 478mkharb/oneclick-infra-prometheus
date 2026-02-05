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

exec > /var/log/user-data.log 2>&1

echo "[BOOT] Starting bootstrap"

for i in {1..30}; do
  ping -c1 8.8.8.8 && break
  sleep 10
done

apt-get update -y

snap install amazon-ssm-agent --classic || true
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

curl -sfL https://get.k3s.io | \
  K3S_URL=https://${aws_instance.k3s_server.private_ip}:6443 \
  K3S_TOKEN=${var.k3s_token} \
  sh -

systemctl enable k3s-agent
systemctl start k3s-agent
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "k3s-worker-node"
      Role    = var.role
      Project = var.project
    }
  }
}
