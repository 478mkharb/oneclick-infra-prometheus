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
set -eux

exec > /var/log/k3s-worker.log 2>&1

apt-get update -y
apt-get install -y curl iptables

iptables -P FORWARD ACCEPT
sysctl -w net.ipv4.ip_forward=1

snap install amazon-ssm-agent --classic || true
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

K3S_URL="https://${aws_instance.k3s_server.private_ip}:6443"

# wait for server
until curl -k $K3S_URL; do
  sleep 10
done

# fetch token securely
TOKEN=$(ssh -o StrictHostKeyChecking=no ubuntu@${aws_instance.k3s_server.private_ip} \
  "sudo cat /var/lib/rancher/k3s/server/node-token")

curl -sfL https://get.k3s.io | \
  K3S_URL=$K3S_URL \
  K3S_TOKEN=$TOKEN \
  sh -
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
