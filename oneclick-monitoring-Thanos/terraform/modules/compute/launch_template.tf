resource "aws_launch_template" "k3s_worker_lt" {
  name_prefix   = "k3s-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_monitoring

  iam_instance_profile {
    name = "ec2-ssm-profile"
  }

  vpc_security_group_ids = [
    var.private_ec2_sg_id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
set -ux
exec > /var/log/k3s-worker.log 2>&1

apt-get update -y
apt-get install -y curl

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

curl -sfL https://get.k3s.io | \
  K3S_URL=https://10.0.3.10:6443 \
  K3S_TOKEN=${var.k3s_token} \
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
